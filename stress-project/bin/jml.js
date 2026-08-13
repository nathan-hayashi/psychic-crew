#!/usr/bin/env node
/**
 * jml — CLI entry point for the identity-lifecycle simulator.
 *
 * Reads one HRIS delivery envelope, runs it through intake -> lifecycle -> IAM
 * -> ticketing -> notify, and appends one audit line per stage.
 *
 * stdout is always a single JSON document and nothing else, so a harness can
 * pipe it straight into a parser. Everything conversational goes to stderr.
 *
 * Exit codes are part of the contract:
 *   0  every event was handled; a deduplicated redelivery counts as handled
 *   1  the run completed but something needs a human: an event was parked,
 *      rejected, illegal for the current state, or its IAM call failed
 *   2  the input was unusable — malformed bytes or unusable arguments. stdout
 *      is then exactly a FALLBACK block (the six keys from the crew protocol),
 *      one rejection line lands in the audit log, and nothing else is written.
 */

import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { parseArgs } from "node:util";
import process from "node:process";

import { resolveClock } from "../src/adapters/clock.js";
import { createIamAdapter } from "../src/adapters/iam.js";
import { STAGES, createAuditLog, fallbackRecord } from "../src/audit.js";
import { createIntake, parseDelivery } from "../src/intake.js";
import { OUTCOMES, createLifecycle } from "../src/lifecycle.js";
import { buildNotification } from "../src/notify.js";
import {
  buildTicket,
  shouldOpenTicket,
  writeTicket,
} from "../src/ticketing.js";

const PACKAGE_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const EXIT = Object.freeze({ OK: 0, NEEDS_HUMAN: 1, UNUSABLE_INPUT: 2 });
const STATE_VERSION = 1;

const USAGE = `jml — identity lifecycle simulator (Joiner / Mover / Leaver)

USAGE
  node bin/jml.js <delivery.json> [options]
  node bin/jml.js - [options]            read the delivery envelope from stdin
  node bin/jml.js --help

OPTIONS
  --out <dir>        artifact directory (default: tmp/run-<run_id>). Reusing one
                     directory across runs shares the audit log and the state,
                     which is how a parked event is replayed by a later delivery.
  --state <file>     state file (default: <out>/state.json)
  --audit <file>     audit log (default: <out>/audit.jsonl)
  --now <iso>        fix the clock at this instant, making the run reproducible
  --seed <string>    seed generated ids, making the run reproducible
  --step-ms <n>      synthetic clock increment per call (default 1000)
  --fail-iam <what>  force IAM failures: create | transfer | suspend | all
  --channel <name>   chat channel for notifications (default: #it-identity)
  --help, -h         print this text

OUTPUT
  stdout  one JSON document: the run report, or a FALLBACK block on exit 2
  stderr  human-readable progress
  <out>/audit.jsonl, <out>/tickets/*.json, <out>/notifications/*.json

EXIT CODES
  0 handled   1 needs a human   2 unusable input

EXAMPLES
  node bin/jml.js fixtures/edge-duplicate-webhook.json
  node bin/jml.js fixtures/edge-mover-before-hire.json --out tmp/replay
  node bin/jml.js fixtures/edge-malformed-payload.json.txt ; echo $?
  node bin/jml.js fixtures/edge-duplicate-webhook.json --now 2026-01-01T00:00:00.000Z --seed s1
`;

const OPTIONS = {
  out: { type: "string" },
  state: { type: "string" },
  audit: { type: "string" },
  now: { type: "string" },
  seed: { type: "string" },
  "step-ms": { type: "string" },
  "fail-iam": { type: "string" },
  channel: { type: "string" },
  help: { type: "boolean", short: "h", default: false },
};

function emitFallbackAndExit(fallback, { auditPath, clock, runId } = {}) {
  if (auditPath && clock) {
    createAuditLog({ path: auditPath, clock, runId }).append(STAGES.INTAKE, {
      outcome: "MALFORMED",
      detail: fallback.reason,
      fallback,
    });
  }
  process.stdout.write(`${JSON.stringify(fallback, null, 2)}\n`);
  return EXIT.UNUSABLE_INPUT;
}

function loadState(path) {
  const empty = {
    version: STATE_VERSION,
    employees: {},
    parked: {},
    seenEventIds: [],
    seenFingerprints: [],
    ticketSequence: 0,
  };
  if (!path || !existsSync(path)) return empty;
  try {
    return { ...empty, ...JSON.parse(readFileSync(path, "utf8")) };
  } catch {
    // A corrupt state file must not silently reset the world: say so, and start
    // clean rather than pretending the previous history was empty.
    process.stderr.write(
      `warning: state file ${path} is unreadable; starting from an empty state\n`,
    );
    return empty;
  }
}

function saveState(path, state) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, `${JSON.stringify(state, null, 2)}\n`, "utf8");
}

function readInput(target) {
  if (target === "-") return readFileSync(0, "utf8");
  return readFileSync(resolve(process.cwd(), target), "utf8");
}

function main(argv) {
  let parsed;
  try {
    parsed = parseArgs({
      args: argv,
      options: OPTIONS,
      allowPositionals: true,
    });
  } catch (error) {
    process.stderr.write(`${USAGE}\n`);
    return emitFallbackAndExit(
      fallbackRecord({
        agent: "jml-cli",
        taskId: "jml-cli-args",
        reason: `unusable arguments: ${error.message}`,
        missing: ["a supported option set"],
        how: "run with --help and re-issue the command with documented options",
        why: "guessing at what an unknown flag meant could silently change which account is touched",
        confidence: 0.1,
      }),
    );
  }

  const { values, positionals } = parsed;
  if (values.help) {
    process.stdout.write(USAGE);
    return EXIT.OK;
  }

  const target = positionals[0];
  if (!target) {
    process.stderr.write(`${USAGE}\n`);
    return emitFallbackAndExit(
      fallbackRecord({
        agent: "jml-cli",
        taskId: "jml-cli-args",
        reason: "no delivery envelope was supplied",
        missing: ["a path to a delivery envelope, or - to read one from stdin"],
        how: "pass a fixture path, for example: node bin/jml.js fixtures/edge-duplicate-webhook.json",
        why: "running with no input would report success for work that never happened",
        confidence: 0.1,
      }),
    );
  }

  const clock = resolveClock({
    now: values.now,
    seed: values.seed,
    stepMs: values["step-ms"] ? Number(values["step-ms"]) : undefined,
  });
  const runId = clock.newId("run");
  const outDir = values.out
    ? resolve(process.cwd(), values.out)
    : join(PACKAGE_ROOT, "tmp", runId);
  const auditPath = values.audit
    ? resolve(process.cwd(), values.audit)
    : join(outDir, "audit.jsonl");
  const statePath = values.state
    ? resolve(process.cwd(), values.state)
    : join(outDir, "state.json");

  let raw;
  try {
    raw = readInput(target);
  } catch (error) {
    return emitFallbackAndExit(
      fallbackRecord({
        agent: "jml-cli",
        taskId: "jml-cli-input",
        reason: `delivery could not be read: ${error.message}`,
        missing: [`a readable file at ${target}`],
        how: "check the path and re-run; use - to read the envelope from stdin",
        why: "an unreadable delivery is indistinguishable from a dropped one and must not exit 0",
        confidence: 0.1,
      }),
      { auditPath, clock, runId },
    );
  }

  const delivery = parseDelivery(raw, {
    taskId: "jml-cli-intake",
    source: target,
  });
  if (!delivery.ok) {
    process.stderr.write(`intake rejected the delivery (${delivery.code})\n`);
    return emitFallbackAndExit(delivery.fallback, { auditPath, clock, runId });
  }

  const state = loadState(statePath);
  const audit = createAuditLog({ path: auditPath, clock, runId });
  const intake = createIntake({
    clock,
    seenEventIds: state.seenEventIds,
    seenFingerprints: state.seenFingerprints,
  });
  const lifecycle = createLifecycle({
    clock,
    employees: state.employees,
    parked: state.parked,
  });
  const iam = createIamAdapter({
    clock,
    failOn: values["fail-iam"] ? [values["fail-iam"]] : [],
  });

  const report = {
    run_id: runId,
    delivery_id: delivery.delivery.delivery_id,
    source: delivery.delivery.source,
    deterministic: clock.deterministic === true,
    out_dir: outDir,
    audit_path: auditPath,
    state_path: statePath,
    counts: {
      events: delivery.delivery.events.length,
      accepted: 0,
      duplicate: 0,
      rejected: 0,
    },
    outcomes: [],
    tickets: [],
    notifications: [],
    fallbacks: [],
  };

  let ticketSequence = state.ticketSequence ?? 0;
  let needsHuman = false;

  const settle = (event, result) => {
    audit.append(STAGES.LIFECYCLE, {
      delivery_id: report.delivery_id,
      event_id: result.event_id,
      employee_id: result.employee_id,
      outcome: result.outcome,
      detail: result.detail,
      ...(result.fallback ? { fallback: result.fallback } : {}),
    });
    report.outcomes.push({
      event_id: result.event_id,
      outcome: result.outcome,
      emission: result.emission,
    });
    if (result.fallback) report.fallbacks.push(result.fallback);
    if (!result.ok) {
      needsHuman = true;
      return;
    }
    if (!shouldOpenTicket(result)) return;

    const iamResult = iam.apply({
      action: result.emission,
      employeeId: result.employee_id,
      event,
    });
    if (!iamResult.ok) needsHuman = true;

    ticketSequence += 1;
    const ticket = buildTicket(
      { event, lifecycle: result, iam: iamResult, sequence: ticketSequence },
      { clock },
    );
    const ticketPath = writeTicket(ticket, join(outDir, "tickets"));
    audit.append(STAGES.TICKETING, {
      delivery_id: report.delivery_id,
      event_id: result.event_id,
      employee_id: result.employee_id,
      outcome: iamResult.ok ? "TICKET_CREATED" : "TICKET_FAILED",
      detail: ticket.key,
    });
    report.tickets.push({
      key: ticket.key,
      status: ticket.fields.status.name,
      path: ticketPath,
    });

    const notification = buildNotification(
      { event, lifecycle: result, ticket, iam: iamResult },
      { clock, channel: values.channel },
    );
    mkdirSync(join(outDir, "notifications"), { recursive: true });
    const notificationPath = join(
      outDir,
      "notifications",
      `${notification.notification_id}.json`,
    );
    writeFileSync(
      notificationPath,
      `${JSON.stringify(notification, null, 2)}\n`,
      "utf8",
    );
    audit.append(STAGES.NOTIFY, {
      delivery_id: report.delivery_id,
      event_id: result.event_id,
      employee_id: result.employee_id,
      outcome: "NOTIFIED",
      detail: notification.channel,
    });
    report.notifications.push({
      id: notification.notification_id,
      channel: notification.channel,
      path: notificationPath,
    });
  };

  for (const rawEvent of delivery.delivery.events) {
    const admitted = intake.admit(rawEvent, {
      delivery: delivery.delivery,
      taskId: "jml-cli-intake",
    });
    audit.append(STAGES.INTAKE, {
      delivery_id: report.delivery_id,
      event_id: admitted.event_id,
      employee_id: admitted.employee_id,
      outcome: admitted.status,
      detail: admitted.duplicate_of
        ? `duplicate by ${admitted.duplicate_of}`
        : (admitted.errors?.map((e) => e.code).join(",") ?? null),
      ...(admitted.fallback ? { fallback: admitted.fallback } : {}),
    });

    if (admitted.status === "REJECTED") {
      report.counts.rejected += 1;
      report.fallbacks.push(admitted.fallback);
      needsHuman = true;
      continue;
    }
    if (admitted.status === "DUPLICATE") {
      report.counts.duplicate += 1;
      continue;
    }

    report.counts.accepted += 1;
    const { result, replays } = lifecycle.apply(admitted.event);
    settle(admitted.event, result);
    for (const { result: replayed, event: heldEvent } of replays) {
      settle(heldEvent, replayed);
    }
  }

  const snapshot = lifecycle.snapshot();
  saveState(statePath, {
    version: STATE_VERSION,
    employees: snapshot.employees,
    parked: snapshot.parked,
    ...intake.snapshot(),
    ticketSequence,
  });

  report.audit_lines = audit.count();
  report.exit_code = needsHuman ? EXIT.NEEDS_HUMAN : EXIT.OK;
  process.stdout.write(`${JSON.stringify(report, null, 2)}\n`);
  process.stderr.write(
    `run ${runId}: ${report.counts.accepted} accepted, ${report.counts.duplicate} duplicate, ${report.counts.rejected} rejected\n`,
  );
  return report.exit_code;
}

process.exitCode = main(process.argv.slice(2));
