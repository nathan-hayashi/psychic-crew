/**
 * D4 — injectable time and identity.
 *
 * Every module in this app takes its `now()` and `newId()` from a clock passed
 * in as a dependency. Nothing calls `Date.now()`, `new Date()` or `randomUUID()`
 * directly. That is not style: an audit trail whose timestamps and ids come from
 * ambient state can only be checked by eye, and "the demo looked right" is not a
 * machine-checkable assertion. With the clock injected, two runs given the same
 * `startedAt` and `seed` produce byte-identical audit lines, so the whole
 * pipeline becomes diffable.
 *
 * Two implementations:
 *   systemClock() — real wall time, random ids. Production path.
 *   fixedClock()  — monotonic synthetic time, seeded ids. Test and replay path.
 *
 * Both satisfy the same shape: { now(), newId(prefix), deterministic }.
 */

import { createHash, randomUUID } from "node:crypto";

/** Synthetic time advances by this much on every now() call. */
export const DEFAULT_STEP_MS = 1000;

const ID_HEX_LENGTH = 12;

function assertPrefix(prefix) {
  if (typeof prefix !== "string" || prefix.length === 0) {
    // Programmer error, not a domain outcome: throw.
    throw new TypeError("newId(prefix) requires a non-empty string prefix");
  }
}

/**
 * Real time, random identity. `deterministic` is false so callers can refuse to
 * make reproducibility claims about a run that used it.
 */
export function systemClock() {
  return {
    deterministic: false,
    now() {
      return new Date().toISOString();
    },
    newId(prefix) {
      assertPrefix(prefix);
      return `${prefix}_${randomUUID().replace(/-/g, "").slice(0, ID_HEX_LENGTH)}`;
    },
  };
}

/**
 * Synthetic time, seeded identity.
 *
 * now() returns startedAt, then startedAt+step, then +2*step ... so consecutive
 * audit lines are ordered and distinct without being wall-clock dependent.
 * newId() is a pure function of (seed, prefix, call-index), so the same run
 * replayed produces the same ids.
 */
export function fixedClock({
  startedAt = "2026-01-01T00:00:00.000Z",
  seed = "jml-fixed-seed",
  stepMs = DEFAULT_STEP_MS,
} = {}) {
  const base = Date.parse(startedAt);
  if (Number.isNaN(base)) {
    throw new TypeError(
      `fixedClock(startedAt) is not a parseable timestamp: ${String(startedAt)}`,
    );
  }
  let ticks = 0;
  const counters = new Map();

  return {
    deterministic: true,
    seed,
    startedAt: new Date(base).toISOString(),
    now() {
      const at = new Date(base + ticks * stepMs).toISOString();
      ticks += 1;
      return at;
    },
    newId(prefix) {
      assertPrefix(prefix);
      const n = (counters.get(prefix) ?? 0) + 1;
      counters.set(prefix, n);
      const digest = createHash("sha256")
        .update(`${seed}:${prefix}:${n}`)
        .digest("hex");
      return `${prefix}_${digest.slice(0, ID_HEX_LENGTH)}`;
    },
  };
}

/**
 * Build a clock from CLI-shaped options. Presence of either determinism knob
 * selects the fixed clock — a half-injected clock is worse than neither, since
 * it looks reproducible and is not.
 */
export function resolveClock({ now, seed, stepMs } = {}) {
  if (now === undefined && seed === undefined) return systemClock();
  return fixedClock({
    startedAt: now ?? "2026-01-01T00:00:00.000Z",
    seed: seed ?? "jml-fixed-seed",
    stepMs,
  });
}
