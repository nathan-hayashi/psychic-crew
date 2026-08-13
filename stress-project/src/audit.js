/**
 * (e) Audit trail — append-only JSONL writer, plus the D5 failure record.
 *
 * One stage, one line. `append()` writes exactly one newline-terminated JSON
 * object per call and returns the line it wrote, so a caller can assert on the
 * bytes rather than on the intent. Records carry a monotonic `seq` from the
 * injected clock's id counter, so ordering survives a same-millisecond flush.
 *
 * D5 lives here too. The app's failure block reuses the crew FALLBACK schema
 * from .claude/rules/fallback-protocol.md verbatim — the same six keys, in the
 * same order. That makes "the run FALLBACK'd cleanly" a key-set assertion
 * instead of a judgement call, which is the only form a gate can check.
 */

import { appendFileSync, mkdirSync, readFileSync, existsSync } from "node:fs";
import { dirname } from "node:path";

/** The D5 contract: exactly these keys, exactly this order. */
export const FALLBACK_KEYS = Object.freeze([
  "agent",
  "task_id",
  "reason",
  "missing",
  "proposed_next_iteration",
  "confidence",
]);

/** Below this, the protocol requires a FALLBACK rather than a guess. */
export const FALLBACK_CONFIDENCE_CEILING = 0.6;

export const STAGES = Object.freeze({
  INTAKE: "intake",
  LIFECYCLE: "lifecycle",
  TICKETING: "ticketing",
  NOTIFY: "notify",
});

/**
 * Build a FALLBACK record. Confidence is clamped strictly below the ceiling:
 * a "fallback" claiming 0.9 confidence is a contradiction, and letting one
 * through would make the `confidence < 0.6` assertion decorative.
 */
export function fallbackRecord({
  agent,
  taskId,
  reason,
  missing = [],
  how,
  why,
  confidence = 0.3,
}) {
  if (typeof reason !== "string" || reason.length === 0) {
    throw new TypeError("fallbackRecord(reason) is required");
  }
  const bounded = Number.isFinite(confidence)
    ? Math.min(Math.max(confidence, 0), FALLBACK_CONFIDENCE_CEILING - 0.01)
    : 0.3;
  return {
    agent: agent ?? "jml-simulator",
    task_id: taskId ?? "unknown-task",
    reason,
    missing: Array.isArray(missing) ? missing : [missing],
    proposed_next_iteration: {
      how: how ?? "supply the missing input and re-deliver the event",
      why: why ?? "the pipeline cannot proceed without it and will not guess",
    },
    confidence: Number(bounded.toFixed(2)),
  };
}

/** True when `value` has the six D5 keys and nothing else. */
export function isFallbackShaped(value) {
  if (value === null || typeof value !== "object" || Array.isArray(value))
    return false;
  const keys = Object.keys(value).sort();
  return (
    keys.length === FALLBACK_KEYS.length &&
    keys.join(",") === [...FALLBACK_KEYS].sort().join(",")
  );
}

/**
 * Append-only JSONL log.
 *
 * `path` may be omitted, in which case the log is memory-only — used by unit
 * tests that assert on line counts without touching the filesystem.
 */
export function createAuditLog({ path, clock, runId } = {}) {
  if (
    !clock ||
    typeof clock.now !== "function" ||
    typeof clock.newId !== "function"
  ) {
    throw new TypeError(
      "createAuditLog requires an injected clock with now() and newId()",
    );
  }
  const lines = [];
  const id = runId ?? clock.newId("run");
  let seq = 0;

  if (path) mkdirSync(dirname(path), { recursive: true });

  return {
    runId: id,
    path: path ?? null,
    append(stage, record = {}) {
      seq += 1;
      const entry = {
        ts: clock.now(),
        run_id: id,
        seq,
        stage,
        delivery_id: record.delivery_id ?? null,
        event_id: record.event_id ?? null,
        employee_id: record.employee_id ?? null,
        outcome: record.outcome ?? "UNKNOWN",
        detail: record.detail ?? null,
        // The REASON a run needed a human, not merely that it did. Dropping it
        // here left the outcome persisted and its D5 block — reason, missing
        // set, confidence — only ever on stdout, which is the "blocking without
        // an audit line is a silent control" failure in a different codebase.
        // Added only when present, so a routine stage line keeps its nine keys.
        ...(record.fallback ? { fallback: record.fallback } : {}),
      };
      const line = `${JSON.stringify(entry)}\n`;
      if (path) appendFileSync(path, line, "utf8");
      lines.push(line);
      return line;
    },
    /** Lines this log instance wrote, in order. */
    lines() {
      return [...lines];
    },
    count() {
      return lines.length;
    },
  };
}

/** Read a JSONL audit file back into objects. Used by the e2e assertions. */
export function readAuditLog(path) {
  if (!existsSync(path)) return [];
  return readFileSync(path, "utf8")
    .split("\n")
    .filter((line) => line.trim().length > 0)
    .map((line) => JSON.parse(line));
}
