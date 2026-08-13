/**
 * (e) Audit test — one stage, one line, no exceptions.
 *
 * The assertion binds to the BYTES on disk, not to the writer's own line
 * counter: `count()` would agree with itself even if appendFileSync were never
 * called. Runtime output goes to a temp directory under stress-project/tmp/
 * (gitignored) and is removed afterwards, so the test leaves no trace in the
 * repo tree.
 */

import { test } from "node:test";
import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, readFileSync, rmSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { fixedClock } from "../src/adapters/clock.js";
import {
  STAGES,
  createAuditLog,
  fallbackRecord,
  isFallbackShaped,
  readAuditLog,
} from "../src/audit.js";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const STAGE_ORDER = [
  STAGES.INTAKE,
  STAGES.LIFECYCLE,
  STAGES.TICKETING,
  STAGES.NOTIFY,
];

test("every-stage-appends-exactly-one-jsonl-line", (t) => {
  mkdirSync(join(ROOT, "tmp"), { recursive: true });
  const dir = mkdtempSync(join(ROOT, "tmp", "audit-case-"));
  t.after(() => rmSync(dir, { recursive: true, force: true }));

  const path = join(dir, "audit.jsonl");
  const log = createAuditLog({
    path,
    clock: fixedClock({
      startedAt: "2026-05-01T00:00:00.000Z",
      seed: "audit-suite",
    }),
    runId: "run_fixed0001",
  });

  const returned = STAGE_ORDER.map((stage, index) =>
    log.append(stage, {
      delivery_id: "whd_test0001",
      event_id: "evt_test-0001",
      employee_id: "EMP-90005",
      outcome: "OK",
      detail: `stage ${index}`,
    }),
  );

  for (const [index, line] of returned.entries()) {
    assert.equal(line.endsWith("\n"), true, `line ${index} must be terminated`);
    assert.equal(
      line.split("\n").length,
      2,
      `line ${index} must contain exactly one newline — one record, one line`,
    );
    assert.doesNotThrow(() => JSON.parse(line));
  }

  const onDisk = readFileSync(path, "utf8");
  assert.equal(
    onDisk,
    returned.join(""),
    "the returned lines must be the bytes that reached the file",
  );

  const records = readAuditLog(path);
  assert.equal(records.length, STAGE_ORDER.length);
  assert.deepEqual(
    records.map((record) => record.stage),
    STAGE_ORDER,
    "one line per stage, in call order",
  );
  assert.deepEqual(
    records.map((record) => record.seq),
    [1, 2, 3, 4],
    "seq is monotonic, so ordering survives a same-millisecond flush",
  );
  assert.deepEqual(
    records.map((record) => record.run_id),
    Array(4).fill("run_fixed0001"),
  );
  assert.deepEqual(
    records.map((record) => record.ts),
    [
      "2026-05-01T00:00:00.000Z",
      "2026-05-01T00:00:01.000Z",
      "2026-05-01T00:00:02.000Z",
      "2026-05-01T00:00:03.000Z",
    ],
    "injected clock: timestamps are constants, not wall time",
  );
  assert.deepEqual(Object.keys(records[0]), [
    "ts",
    "run_id",
    "seq",
    "stage",
    "delivery_id",
    "event_id",
    "employee_id",
    "outcome",
    "detail",
  ]);
  assert.equal(log.count(), STAGE_ORDER.length);

  // A fifth append adds exactly one more line, not a rewrite of the file.
  const fifth = log.append(STAGES.INTAKE, { outcome: "OK" });
  assert.equal(readFileSync(path, "utf8"), `${onDisk}${fifth}`);
  assert.equal(readAuditLog(path).length, 5);

  // A needs-a-human record carries its REASON to disk, not only its verdict.
  // The nine-key assertion above is the other half of this: the D5 block is
  // added when present and never manufactured when it is not, so a routine
  // stage line keeps its shape while a denial stops being a silent control.
  const reason = fallbackRecord({
    agent: "lifecycle",
    taskId: "audit-suite",
    reason: "event evt_test-0002 is not a legal transition out of SUSPENDED",
    missing: ["an explanation for how EMP-90005 reached SUSPENDED"],
    confidence: 0.25,
  });
  log.append(STAGES.LIFECYCLE, {
    event_id: "evt_test-0002",
    outcome: "INVALID_TRANSITION",
    detail: "illegal",
    fallback: reason,
  });

  const persisted = readAuditLog(path);
  assert.equal(persisted.length, 6);
  const denial = persisted[5];
  assert.equal(
    isFallbackShaped(denial.fallback),
    true,
    "the persisted line must carry the six-key D5 block, not just the outcome",
  );
  assert.deepEqual(denial.fallback, reason);
  assert.equal(
    Object.prototype.hasOwnProperty.call(persisted[0], "fallback"),
    false,
    "a record with no fallback must not gain an empty one",
  );
});
