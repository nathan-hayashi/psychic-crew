/**
 * End-to-end — a leaver, through the real CLI, to a full audit trail.
 *
 * The CLI is spawned with `spawnSync` and its result is CAPTURED INTO A
 * VARIABLE before anything is asserted. No shell, no pipeline: a stage exiting
 * nonzero is meaningful here (1 = needs a human, 2 = unusable input), and a
 * pipeline would swallow exactly the signal under test.
 *
 * The run is fixed with --now and --seed, so the second half of this case can
 * assert that a rerun into a different directory produces a byte-identical
 * audit log.
 */

import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import {
  mkdirSync,
  mkdtempSync,
  readFileSync,
  readdirSync,
  rmSync,
} from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import process from "node:process";

import { findSecretShapes } from "../src/notify.js";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const CLI = join(ROOT, "bin", "jml.js");
const FIXTURE = join(ROOT, "fixtures", "leaver-bulbasaur.json");
const FIXED_NOW = "2026-06-01T00:00:00.000Z";
const SEED = "e2e-leaver";

function runCli(outDir) {
  return spawnSync(
    process.execPath,
    [CLI, FIXTURE, "--out", outDir, "--now", FIXED_NOW, "--seed", SEED],
    { cwd: ROOT, encoding: "utf8" },
  );
}

test("leaver-suspend-ticket-notify-full-trail", (t) => {
  mkdirSync(join(ROOT, "tmp"), { recursive: true });
  const dir = mkdtempSync(join(ROOT, "tmp", "e2e-case-"));
  t.after(() => rmSync(dir, { recursive: true, force: true }));

  const outDir = join(dir, "run-a");
  const run = runCli(outDir);

  assert.equal(
    run.status,
    0,
    `CLI exited ${run.status}; stderr: ${run.stderr}`,
  );
  assert.equal(run.error, undefined);

  const report = JSON.parse(run.stdout);
  assert.equal(report.deterministic, true);
  assert.equal(report.delivery_id, "whd_c4e07b930001");
  assert.deepEqual(report.counts, {
    events: 1,
    accepted: 1,
    duplicate: 0,
    rejected: 0,
  });
  assert.deepEqual(report.fallbacks, [], "a clean leaver needs no FALLBACK");
  assert.equal(report.exit_code, 0);
  assert.equal(report.audit_lines, 4);

  // The trail: one line per stage, in pipeline order.
  const audit = readFileSync(join(outDir, "audit.jsonl"), "utf8");
  const records = audit
    .split("\n")
    .filter((line) => line.trim().length > 0)
    .map((line) => JSON.parse(line));

  assert.deepEqual(
    records.map((record) => [record.stage, record.outcome]),
    [
      ["intake", "ACCEPTED"],
      ["lifecycle", "APPLIED"],
      ["ticketing", "TICKET_CREATED"],
      ["notify", "NOTIFIED"],
    ],
    "suspend -> ticket -> notify must each leave exactly one audited line",
  );
  assert.deepEqual(
    records.map((record) => record.employee_id),
    Array(4).fill("EMP-10047"),
  );
  assert.deepEqual(
    records.map((record) => record.seq),
    [1, 2, 3, 4],
  );
  assert.equal(
    records.every((record) => record.run_id === report.run_id),
    true,
  );
  assert.match(records[1].detail, /ACTIVE -> SUSPENDED|NONE -> SUSPENDED/);

  // The ticket.
  const ticketFiles = readdirSync(join(outDir, "tickets"));
  assert.deepEqual(ticketFiles, ["JML-0001.json"]);
  const ticket = JSON.parse(
    readFileSync(join(outDir, "tickets", "JML-0001.json"), "utf8"),
  );
  assert.equal(ticket.fields.status.name, "Done");
  assert.equal(ticket.fields.priority.name, "Medium");
  assert.equal(ticket.fields.customfield_iam_action, "iam.suspend");
  assert.equal(ticket.fields.customfield_employee_id, "EMP-10047");
  assert.equal(
    ticket.fields.customfield_event_id,
    "evt_c4e07b93-term-bulbasaur",
  );
  assert.equal(ticket.fields.duedate, "2026-08-15");

  // The notification.
  const notificationFiles = readdirSync(join(outDir, "notifications"));
  assert.equal(notificationFiles.length, 1);
  const notification = JSON.parse(
    readFileSync(join(outDir, "notifications", notificationFiles[0]), "utf8"),
  );
  assert.equal(notification.channel, "#it-identity");
  assert.equal(notification.blocks.length, 3);
  assert.deepEqual(
    findSecretShapes(notification),
    [],
    "nothing credential-shaped may reach the channel, even end to end",
  );
  assert.equal(
    JSON.stringify(notification).includes("bulbasaur.overgrow@example.invalid"),
    false,
    "the work email belongs on the ticket, not in the channel",
  );

  // Determinism (D4): same --now and --seed, different directory, same bytes.
  const rerunDir = join(dir, "run-b");
  const rerun = runCli(rerunDir);
  assert.equal(
    rerun.status,
    0,
    `rerun exited ${rerun.status}: ${rerun.stderr}`,
  );
  assert.equal(
    readFileSync(join(rerunDir, "audit.jsonl"), "utf8"),
    audit,
    "a seeded rerun must be byte-identical, or the trail is not reproducible",
  );
});
