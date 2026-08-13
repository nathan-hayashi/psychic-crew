/**
 * (a) Intake — parse, validate, dedupe.
 *
 * The HRIS posts one delivery envelope per webhook:
 *   { delivery_id, source, api_version, received_at, events: [ ... ] }
 * A delivery carries one or more events; a redelivery carries the same events
 * again, sometimes with cosmetic differences in whitespace. Both facts come
 * from the fixtures, not from an assumed shape.
 *
 * Nothing here throws on bad input. Malformed bytes, a missing field and a
 * redelivery are all expected operational events, so each returns a result
 * object a test can assert on. Throwing is reserved for our own mistakes.
 */

import { createHash } from "node:crypto";
import { fallbackRecord } from "./audit.js";

export const EVENT_TYPES = Object.freeze(["HIRE", "MOVE", "TERMINATE"]);

export const REJECT_CODES = Object.freeze({
  MISSING_FIELD: "MISSING_FIELD",
  UNKNOWN_EVENT_TYPE: "UNKNOWN_EVENT_TYPE",
  NOT_AN_OBJECT: "NOT_AN_OBJECT",
});

const REQUIRED_EVENT_FIELDS = Object.freeze([
  "event_id",
  "event_type",
  "employee_id",
  "occurred_at",
]);
const REQUIRED_ENVELOPE_FIELDS = Object.freeze([
  "delivery_id",
  "source",
  "api_version",
  "received_at",
  "events",
]);

const isObject = (value) =>
  value !== null && typeof value === "object" && !Array.isArray(value);

/** Trim and collapse internal whitespace runs. Cosmetic redelivery differences die here. */
function normaliseString(value) {
  return value.replace(/\s+/g, " ").trim();
}

/** Deep copy with every string normalised and every object key sorted. */
function canonicalise(value) {
  if (typeof value === "string") return normaliseString(value);
  if (Array.isArray(value)) return value.map(canonicalise);
  if (isObject(value)) {
    const out = {};
    for (const key of Object.keys(value).sort())
      out[key] = canonicalise(value[key]);
    return out;
  }
  return value;
}

/**
 * Content fingerprint of an event, computed over canonical form.
 *
 * `event_id` is deliberately EXCLUDED. Including it would make this index
 * strictly redundant with the event_id index — every fingerprint collision would
 * already have been an id collision, so the fingerprint could never catch
 * anything on its own and would only look like a second control. What it is
 * actually for is the redelivery that arrives with a FRESH id: an upstream that
 * reserialises on retry changes the id and the whitespace, and leaves the
 * substance identical. Dropping the id is what lets that be caught.
 *
 * The cost, stated: two genuinely distinct events with byte-identical content
 * including `occurred_at` collapse into one. For an HRIS event stream that is
 * itself a duplicate, so the trade is accepted rather than merely unnoticed.
 */
export function fingerprintEvent(event) {
  if (!isObject(event))
    throw new TypeError("fingerprintEvent(event) requires an object");
  const { event_id: _ignoredId, ...content } = event;
  const canonical = canonicalise(content);
  return createHash("sha256").update(JSON.stringify(canonical)).digest("hex");
}

/** Structural validation. Returns a value; never throws on bad data. */
export function validateEvent(event) {
  if (!isObject(event)) {
    return {
      ok: false,
      errors: [
        {
          field: ".",
          code: REJECT_CODES.NOT_AN_OBJECT,
          message: "event must be an object",
        },
      ],
    };
  }
  const errors = [];
  for (const field of REQUIRED_EVENT_FIELDS) {
    const value = event[field];
    if (typeof value !== "string" || normaliseString(value).length === 0) {
      errors.push({
        field,
        code: REJECT_CODES.MISSING_FIELD,
        message: `${field} is required and must be a non-empty string`,
      });
    }
  }
  if (
    typeof event.event_type === "string" &&
    !EVENT_TYPES.includes(normaliseString(event.event_type))
  ) {
    errors.push({
      field: "event_type",
      code: REJECT_CODES.UNKNOWN_EVENT_TYPE,
      message: `event_type must be one of ${EVENT_TYPES.join(", ")}`,
    });
  }
  return { ok: errors.length === 0, errors };
}

/**
 * Parse raw webhook bytes into a delivery envelope.
 *
 * On failure the result carries a D5 FALLBACK block rather than an ad-hoc error
 * string, so the CLI can print it straight to stdout and a gate can assert on
 * its six keys.
 */
export function parseDelivery(
  raw,
  { taskId = "jml-intake", source = "stdin" } = {},
) {
  const text = Buffer.isBuffer(raw) ? raw.toString("utf8") : String(raw ?? "");
  let parsed;
  try {
    parsed = JSON.parse(text);
  } catch (error) {
    return {
      ok: false,
      code: "MALFORMED_JSON",
      fallback: fallbackRecord({
        agent: "intake",
        taskId,
        reason: `delivery bytes are not valid JSON: ${error.message}`,
        missing: ["a parseable JSON delivery envelope"],
        how: `re-request the delivery from ${source} and verify the transport did not truncate it`,
        why: "guessing at the intended payload would fabricate identity changes from corrupt bytes",
        confidence: 0.1,
      }),
    };
  }

  if (!isObject(parsed)) {
    return {
      ok: false,
      code: "MALFORMED_ENVELOPE",
      fallback: fallbackRecord({
        agent: "intake",
        taskId,
        reason: "delivery parsed as JSON but is not an object envelope",
        missing: REQUIRED_ENVELOPE_FIELDS.slice(),
        how: "confirm the sender posts the documented delivery envelope, not a bare array or scalar",
        why: "the envelope is where delivery_id and event ordering live; without it dedupe has no key",
        confidence: 0.15,
      }),
    };
  }

  const missing = REQUIRED_ENVELOPE_FIELDS.filter(
    (field) => parsed[field] === undefined,
  );
  const eventsInvalid =
    !Array.isArray(parsed.events) || parsed.events.length === 0;
  if (missing.length > 0 || eventsInvalid) {
    return {
      ok: false,
      code: "MALFORMED_ENVELOPE",
      fallback: fallbackRecord({
        agent: "intake",
        taskId,
        reason:
          "delivery envelope is missing required fields or carries no events",
        missing:
          missing.length > 0 ? missing : ["events[] must be a non-empty array"],
        how: "ask the sender to redeliver a complete envelope with at least one event",
        why: "an envelope without events is indistinguishable from a dropped payload and must not be treated as a no-op success",
        confidence: 0.2,
      }),
    };
  }

  return {
    ok: true,
    delivery: {
      delivery_id: parsed.delivery_id,
      source: parsed.source,
      api_version: parsed.api_version,
      received_at: parsed.received_at,
      delivery_attempt: parsed.delivery_attempt ?? 1,
      events: parsed.events,
    },
  };
}

/**
 * Stateful intake. Holds the dedupe index for a run and, when restored from a
 * state file, across runs — a redelivery an hour later is still a redelivery.
 *
 * "Already seen" means "already SUCCESSFULLY processed". The distinction is the
 * whole point: an at-least-once HRIS heals a transient provider failure by
 * redelivering, so an index that swallowed every repeat would make the system's
 * own recovery channel the thing that suppresses recovery — a failed suspend
 * would have no retry path at all. An event whose prior attempt ended in a
 * retryable provider failure is therefore re-admitted as a RETRY, not answered
 * DUPLICATE. The cost, stated rather than hidden: the provider call must be
 * genuinely idempotent, because a retry re-issues it.
 */
export function createIntake({
  clock,
  seenEventIds = [],
  seenFingerprints = [],
  failedEventIds = [],
  failedFingerprints = [],
} = {}) {
  if (!clock || typeof clock.now !== "function") {
    throw new TypeError(
      "createIntake requires an injected clock with now() and newId()",
    );
  }
  const byEventId = new Set(seenEventIds);
  const byFingerprint = new Set(seenFingerprints);
  const failedById = new Set(failedEventIds);
  const failedByFingerprint = new Set(failedFingerprints);

  return {
    admit(event, { delivery = {}, taskId = "jml-intake" } = {}) {
      const validation = validateEvent(event);
      if (!validation.ok) {
        return {
          status: "REJECTED",
          event_id: isObject(event) ? (event.event_id ?? null) : null,
          employee_id: isObject(event) ? (event.employee_id ?? null) : null,
          delivery_id: delivery.delivery_id ?? null,
          errors: validation.errors,
          fallback: fallbackRecord({
            agent: "intake",
            taskId,
            reason: `event failed structural validation: ${validation.errors.map((e) => e.code).join(", ")}`,
            missing: validation.errors.map((e) => e.field),
            how: "ask the HRIS to redeliver the event with the required fields populated",
            why: "an identity change applied from an incomplete event would touch the wrong account or none at all",
            confidence: 0.2,
          }),
        };
      }

      const eventId = normaliseString(event.event_id);
      const fingerprint = fingerprintEvent(event);
      const duplicateBy = byEventId.has(eventId)
        ? "event_id"
        : byFingerprint.has(fingerprint)
          ? "fingerprint"
          : null;

      const priorAttemptFailed =
        failedById.has(eventId) || failedByFingerprint.has(fingerprint);

      if (duplicateBy && !priorAttemptFailed) {
        return {
          status: "DUPLICATE",
          event_id: eventId,
          employee_id: normaliseString(event.employee_id),
          delivery_id: delivery.delivery_id ?? null,
          duplicate_of: duplicateBy,
          fingerprint,
        };
      }

      byEventId.add(eventId);
      byFingerprint.add(fingerprint);
      // Cleared on re-admission and re-marked only if this attempt fails too,
      // so a retry that succeeds stops retrying instead of looping forever.
      failedById.delete(eventId);
      failedByFingerprint.delete(fingerprint);
      return {
        status: "ACCEPTED",
        event_id: eventId,
        employee_id: normaliseString(event.employee_id),
        event_type: normaliseString(event.event_type),
        delivery_id: delivery.delivery_id ?? null,
        fingerprint,
        // Present only on a redelivery whose prior attempt failed, so the audit
        // trail distinguishes "first time" from "second chance".
        ...(duplicateBy ? { retry_of: duplicateBy } : {}),
        event: canonicalise(event),
        admitted_at: clock.now(),
      };
    },
    /**
     * Record that this event's provider work failed and may be re-attempted.
     * Keyed on BOTH indexes because a redelivery may arrive with a fresh id and
     * be recognisable only by content fingerprint — which is exactly the case
     * the retry path exists for.
     */
    markFailed(event) {
      const eventId = normaliseString(String(event?.event_id ?? ""));
      if (eventId.length > 0) failedById.add(eventId);
      failedByFingerprint.add(fingerprintEvent(event));
    },
    /** Serialisable dedupe index, for the CLI's state file. */
    snapshot() {
      return {
        seenEventIds: [...byEventId],
        seenFingerprints: [...byFingerprint],
        failedEventIds: [...failedById],
        failedFingerprints: [...failedByFingerprint],
      };
    },
  };
}
