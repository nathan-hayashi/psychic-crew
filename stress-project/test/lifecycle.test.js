/**
 * (b) Lifecycle tests — the transition table and the parking lot.
 *
 * The design rule under test everywhere here: expected failures are VALUES.
 * `applyEvent()` throws only on programmer error (a non-object event, a missing
 * clock), so these cases assert on returned objects. One case asserts that
 * boundary in both directions, because a module that threw on everything and a
 * module that threw on nothing would each satisfy a one-sided test.
 */

import { test } from "node:test";
import assert from "node:assert/strict";

import { fixedClock } from "../src/adapters/clock.js";
import { IAM_ACTIONS } from "../src/adapters/iam.js";
import { isFallbackShaped } from "../src/audit.js";
import {
  OUTCOMES,
  STATES,
  applyEvent,
  createLifecycle,
} from "../src/lifecycle.js";
import { shouldOpenTicket } from "../src/ticketing.js";

const clock = () =>
  fixedClock({
    startedAt: "2026-02-01T00:00:00.000Z",
    seed: "lifecycle-suite",
  });

const event = (type, overrides = {}) => ({
  event_id: `evt_test-${type.toLowerCase()}-0001`,
  event_type: type,
  occurred_at: "2026-02-01T09:00:00.000Z",
  employee_id: "EMP-90002",
  employee: { display_name: "Nils Baird" },
  department: { id: "DEP-OPS", name: "IT Operations" },
  ...overrides,
});

test("hire-none-to-active-emits-create", () => {
  const result = applyEvent(STATES.NONE, event("HIRE"), { clock: clock() });

  assert.equal(result.ok, true);
  assert.equal(result.outcome, OUTCOMES.APPLIED);
  assert.equal(result.from, STATES.NONE);
  assert.equal(result.to, STATES.ACTIVE);
  assert.equal(result.emission, IAM_ACTIONS.CREATE);
  assert.equal(result.decided_at, "2026-02-01T00:00:00.000Z");
  assert.equal(shouldOpenTicket(result), true);
});

test("move-active-emits-transfer", () => {
  const result = applyEvent(STATES.ACTIVE, event("MOVE"), { clock: clock() });

  assert.equal(result.ok, true);
  assert.equal(result.outcome, OUTCOMES.APPLIED);
  assert.equal(result.from, STATES.ACTIVE);
  assert.equal(result.to, STATES.ACTIVE);
  assert.equal(result.emission, IAM_ACTIONS.TRANSFER);
  assert.equal(shouldOpenTicket(result), true);
});

test("terminate-active-to-suspended-emits-suspend", () => {
  const result = applyEvent(STATES.ACTIVE, event("TERMINATE"), {
    clock: clock(),
  });

  assert.equal(result.ok, true);
  assert.equal(result.outcome, OUTCOMES.APPLIED);
  assert.equal(result.from, STATES.ACTIVE);
  assert.equal(result.to, STATES.SUSPENDED);
  assert.equal(result.emission, IAM_ACTIONS.SUSPEND);
  assert.equal(shouldOpenTicket(result), true);
});

test("terminate-twice-is-idempotent", () => {
  const lifecycle = createLifecycle({ clock: clock() });
  lifecycle.apply(event("HIRE"));

  const first = lifecycle.apply(event("TERMINATE")).result;
  assert.equal(first.outcome, OUTCOMES.APPLIED);
  assert.equal(first.emission, IAM_ACTIONS.SUSPEND);
  assert.equal(lifecycle.stateOf("EMP-90002"), STATES.SUSPENDED);

  const second = lifecycle.apply(
    event("TERMINATE", { event_id: "evt_test-terminate-0002" }),
  ).result;
  assert.equal(second.ok, true, "a repeat terminate is a no-op, not an error");
  assert.equal(second.outcome, OUTCOMES.IDEMPOTENT);
  assert.equal(
    second.emission,
    null,
    "a second suspend must not reach the provider",
  );
  assert.equal(
    shouldOpenTicket(second),
    false,
    "no work happened, so no ticket may be opened",
  );
  assert.equal(second.to, STATES.SUSPENDED);
  assert.equal(lifecycle.stateOf("EMP-90002"), STATES.SUSPENDED);
});

test("move-before-hire-parks-and-fallbacks", () => {
  const lifecycle = createLifecycle({ clock: clock() });
  const move = event("MOVE");
  const { result, replays } = lifecycle.apply(move);

  assert.equal(result.ok, false);
  assert.equal(result.outcome, OUTCOMES.PARKED);
  assert.equal(result.from, STATES.NONE);
  assert.equal(result.to, STATES.NONE);
  assert.equal(
    result.emission,
    null,
    "parking must not invent an account the HRIS never authorised",
  );
  assert.deepEqual(replays, []);
  assert.equal(isFallbackShaped(result.fallback), true);
  assert.ok(result.fallback.confidence < 0.6);
  assert.deepEqual(result.fallback.missing, ["a HIRE event for EMP-90002"]);
  assert.equal(lifecycle.parkedFor("EMP-90002").length, 1);
  assert.equal(lifecycle.stateOf("EMP-90002"), STATES.NONE);
});

test("parked-move-replays-after-hire", () => {
  const lifecycle = createLifecycle({ clock: clock() });
  const move = event("MOVE");
  assert.equal(lifecycle.apply(move).result.outcome, OUTCOMES.PARKED);

  const { result, replays } = lifecycle.apply(event("HIRE"));

  assert.equal(result.outcome, OUTCOMES.APPLIED);
  assert.equal(result.emission, IAM_ACTIONS.CREATE);
  assert.equal(replays.length, 1, "the HIRE must drain the parking lot");

  const [replay] = replays;
  assert.equal(
    replay.result.outcome,
    OUTCOMES.REPLAYED,
    "REPLAYED, not APPLIED: the trail must distinguish 'worked first time'",
  );
  assert.equal(replay.result.emission, IAM_ACTIONS.TRANSFER);
  assert.equal(replay.result.from, STATES.ACTIVE);
  assert.equal(
    replay.event.event_id,
    move.event_id,
    "the held event itself must be carried, not the event that unblocked it",
  );
  assert.deepEqual(lifecycle.parkedFor("EMP-90002"), []);
  assert.deepEqual(lifecycle.snapshot().parked, {});
  assert.equal(lifecycle.stateOf("EMP-90002"), STATES.ACTIVE);
});

test("unknown-transition-returns-error-value-not-throw", () => {
  // Domain outcome: illegal, and therefore a VALUE. Asserting a throw here would
  // enforce the opposite of the contract, so the call is made bare and the
  // absence of a throw is asserted explicitly.
  let thrown = null;
  let illegal;
  try {
    illegal = applyEvent(STATES.SUSPENDED, event("MOVE"), { clock: clock() });
  } catch (error) {
    thrown = error;
  }

  assert.equal(thrown, null, "an illegal transition must not throw");
  assert.equal(illegal.ok, false);
  assert.equal(illegal.outcome, OUTCOMES.INVALID_TRANSITION);
  assert.equal(illegal.from, STATES.SUSPENDED);
  assert.equal(illegal.to, STATES.SUSPENDED);
  assert.equal(illegal.emission, null);
  assert.match(illegal.detail, /not a legal transition out of SUSPENDED/);
  assert.equal(illegal.fallback, undefined);

  // An event_type with no row at all takes the same value-returning path.
  const unknownType = applyEvent(STATES.ACTIVE, event("PROMOTE"), {
    clock: clock(),
  });
  assert.equal(unknownType.ok, false);
  assert.equal(unknownType.outcome, OUTCOMES.INVALID_TRANSITION);
  assert.match(unknownType.detail, /no transition from ACTIVE/);

  // The other half of the boundary: programmer error still throws. Without this,
  // a module that never threw at all would also pass the assertions above.
  assert.throws(
    () => applyEvent(STATES.ACTIVE, null, { clock: clock() }),
    TypeError,
  );
  assert.throws(() => applyEvent(STATES.ACTIVE, event("MOVE"), {}), TypeError);
});
