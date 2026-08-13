/**
 * (a) Intake tests — parse, validate, dedupe.
 *
 * Four of these six cases are failure paths, because intake is where the outside
 * world's mistakes arrive. Every one of them asserts a RETURNED value: the module
 * reserves throwing for our own bugs, so a test that caught an exception here
 * would be certifying the opposite of the contract.
 *
 * Time and identity come from a fixedClock, so `admitted_at` is an assertable
 * constant rather than "whenever the suite happened to run".
 */

import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { fixedClock } from "../src/adapters/clock.js";
import { FALLBACK_KEYS, isFallbackShaped } from "../src/audit.js";
import {
  REJECT_CODES,
  createIntake,
  fingerprintEvent,
  parseDelivery,
  validateEvent,
} from "../src/intake.js";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");

const clock = () =>
  fixedClock({ startedAt: "2026-01-01T00:00:00.000Z", seed: "intake-suite" });

const hireEvent = (overrides = {}) => ({
  event_id: "evt_test-hire-0001",
  event_type: "HIRE",
  occurred_at: "2026-01-01T09:00:00.000Z",
  effective_date: "2026-01-15",
  employee_id: "EMP-90001",
  employee: {
    display_name: "Ada Kestrel",
    work_email: "ada.kestrel@example.invalid",
  },
  department: { id: "DEP-ENG", name: "Platform Engineering" },
  entitlements: { grant: ["idp.baseline"], revoke: [] },
  ...overrides,
});

test("parses-valid-hire", () => {
  const raw = readFileSync(
    join(ROOT, "fixtures", "joiner-charmander.json"),
    "utf8",
  );
  const parsed = parseDelivery(raw, {
    source: "fixtures/joiner-charmander.json",
  });

  assert.equal(parsed.ok, true);
  assert.equal(parsed.delivery.delivery_id, "whd_7a1c4e2b0001");
  assert.equal(parsed.delivery.source, "hris.workday");
  assert.equal(parsed.delivery.events.length, 1);

  const [event] = parsed.delivery.events;
  assert.deepEqual(validateEvent(event), { ok: true, errors: [] });

  const admitted = createIntake({ clock: clock() }).admit(event, {
    delivery: parsed.delivery,
  });
  assert.equal(admitted.status, "ACCEPTED");
  assert.equal(admitted.event_type, "HIRE");
  assert.equal(admitted.employee_id, "EMP-10041");
  assert.equal(admitted.event_id, "evt_7a1c4e2b-hire-charmander");
  assert.equal(admitted.delivery_id, "whd_7a1c4e2b0001");
  // Injected clock: the admission stamp is a constant, not wall time.
  assert.equal(admitted.admitted_at, "2026-01-01T00:00:00.000Z");
});

test("rejects-missing-employee-id", () => {
  const { employee_id: _dropped, ...event } = hireEvent();
  const result = createIntake({ clock: clock() }).admit(event, {
    delivery: { delivery_id: "whd_test0001" },
  });

  assert.equal(result.status, "REJECTED");
  assert.deepEqual(
    result.errors.map((error) => [error.field, error.code]),
    [["employee_id", REJECT_CODES.MISSING_FIELD]],
    "the rejection must name the missing field, not merely report failure",
  );
  assert.equal(result.employee_id, null);
  assert.equal(result.delivery_id, "whd_test0001");
  assert.equal(
    isFallbackShaped(result.fallback),
    true,
    "a rejection must carry the D5 six-key block",
  );
  assert.ok(result.fallback.confidence < 0.6);
});

test("rejects-unknown-event-type", () => {
  const result = createIntake({ clock: clock() }).admit(
    hireEvent({ event_type: "PROMOTE" }),
    {},
  );

  assert.equal(result.status, "REJECTED");
  assert.deepEqual(
    result.errors.map((error) => error.code),
    [REJECT_CODES.UNKNOWN_EVENT_TYPE],
  );
  assert.equal(result.errors[0].field, "event_type");
  assert.equal(isFallbackShaped(result.fallback), true);
});

test("dedupes-identical-event-id", () => {
  const intake = createIntake({ clock: clock() });
  const event = hireEvent();

  assert.equal(intake.admit(event, {}).status, "ACCEPTED");

  const second = intake.admit(event, {});
  assert.equal(second.status, "DUPLICATE");
  assert.equal(second.duplicate_of, "event_id");
  assert.equal(second.event_id, "evt_test-hire-0001");
});

test("dedupe-survives-whitespace-variant", () => {
  const intake = createIntake({ clock: clock() });
  const original = hireEvent();

  // A DIFFERENT event_id on purpose. An upstream that reserialises on retry
  // mints a fresh id, so the id index cannot see this one — only the content
  // fingerprint can. Reusing the id here would let the case pass through the id
  // path with normalisation never exercised, which is the defect A3 removed
  // from fingerprintEvent() and which this test exists to keep removed.
  const variant = hireEvent({
    event_id: "evt_test-hire-0001-retry",
    employee: {
      display_name: "  Ada   Kestrel ",
      work_email: "ada.kestrel@example.invalid ",
    },
    department: { name: "Platform  Engineering", id: "DEP-ENG" },
  });

  assert.notEqual(
    variant.event_id,
    original.event_id,
    "the variant must not be catchable by the event_id index",
  );
  assert.equal(
    fingerprintEvent(original),
    fingerprintEvent(variant),
    "whitespace and key order are cosmetic; the fingerprint must not see them",
  );

  assert.equal(intake.admit(original, {}).status, "ACCEPTED");

  const second = intake.admit(variant, {});
  assert.equal(second.status, "DUPLICATE");
  assert.equal(
    second.duplicate_of,
    "fingerprint",
    "must be caught by content, not by id",
  );
  assert.equal(second.event_id, "evt_test-hire-0001-retry");
});

test("malformed-bytes-return-fallback-schema", () => {
  const raw = readFileSync(
    join(ROOT, "fixtures", "edge-malformed-payload.json.txt"),
    "utf8",
  );

  let thrown = null;
  let parsed;
  try {
    parsed = parseDelivery(raw, {
      source: "fixtures/edge-malformed-payload.json.txt",
    });
  } catch (error) {
    thrown = error;
  }

  assert.equal(thrown, null, "corrupt bytes are a domain outcome, not a throw");
  assert.equal(parsed.ok, false);
  assert.equal(parsed.code, "MALFORMED_JSON");
  assert.equal(isFallbackShaped(parsed.fallback), true);
  assert.deepEqual(
    Object.keys(parsed.fallback),
    [...FALLBACK_KEYS],
    "D5 requires these six keys in this order",
  );
  assert.deepEqual(Object.keys(parsed.fallback.proposed_next_iteration), [
    "how",
    "why",
  ]);
  assert.ok(parsed.fallback.confidence < 0.6);
});
