/**
 * (b) Lifecycle — the state machine that turns an HRIS event into an IAM action.
 *
 * States:    NONE -> ACTIVE -> SUSPENDED
 * Events:    HIRE | MOVE | TERMINATE
 * Emissions: iam.create | iam.transfer | iam.suspend
 *
 * `applyEvent()` returns a result object for EVERY domain outcome — applied,
 * idempotent, parked, replayed, invalid — and throws only on programmer error
 * (a non-object event, a missing clock). Expected failures are values, so a
 * test asserts on them instead of wrapping calls in try/catch and hoping the
 * right throw arrived.
 *
 * Out-of-order delivery is real: HRIS systems retry, and a MOVE can arrive
 * before the HIRE that created the account. That is not an error, it is a
 * PARKED event plus a D5 FALLBACK — we decline to invent an account, say what
 * is missing, and replay the move once the HIRE lands.
 */

import { fallbackRecord } from "./audit.js";
import { IAM_ACTIONS } from "./adapters/iam.js";

export const STATES = Object.freeze({
  NONE: "NONE",
  ACTIVE: "ACTIVE",
  SUSPENDED: "SUSPENDED",
});

export const OUTCOMES = Object.freeze({
  APPLIED: "APPLIED",
  IDEMPOTENT: "IDEMPOTENT",
  PARKED: "PARKED",
  REPLAYED: "REPLAYED",
  INVALID_TRANSITION: "INVALID_TRANSITION",
});

/**
 * The whole transition table, in one readable place. `emission: null` means the
 * outcome is real but no IAM call is warranted — suspending an already
 * suspended account must not call the provider a second time.
 *
 * Note the deliberate asymmetry in the NONE row, since it is the row a reviewer
 * should argue with. Both MOVE and TERMINATE can arrive for an employee this
 * system has never seen, and they are answered differently on purpose:
 *
 *   NONE + MOVE      -> PARKED. Acting would have to invent an account, and the
 *                       error would GRANT access the HRIS never authorised.
 *   NONE + TERMINATE -> suspend anyway. Declining would RETAIN access until a
 *                       human noticed, and a missed revoke is a security
 *                       incident where a redundant one is a no-op.
 *
 * The rule underneath both is the same: when delivery order is uncertain, err
 * toward less access, never toward more.
 */
const TRANSITIONS = Object.freeze({
  [STATES.NONE]: {
    HIRE: {
      to: STATES.ACTIVE,
      emission: IAM_ACTIONS.CREATE,
      outcome: OUTCOMES.APPLIED,
    },
    MOVE: { to: STATES.NONE, emission: null, outcome: OUTCOMES.PARKED },
    TERMINATE: {
      to: STATES.SUSPENDED,
      emission: IAM_ACTIONS.SUSPEND,
      outcome: OUTCOMES.APPLIED,
    },
  },
  [STATES.ACTIVE]: {
    HIRE: { to: STATES.ACTIVE, emission: null, outcome: OUTCOMES.IDEMPOTENT },
    MOVE: {
      to: STATES.ACTIVE,
      emission: IAM_ACTIONS.TRANSFER,
      outcome: OUTCOMES.APPLIED,
    },
    TERMINATE: {
      to: STATES.SUSPENDED,
      emission: IAM_ACTIONS.SUSPEND,
      outcome: OUTCOMES.APPLIED,
    },
  },
  [STATES.SUSPENDED]: {
    HIRE: {
      to: STATES.SUSPENDED,
      emission: null,
      outcome: OUTCOMES.INVALID_TRANSITION,
    },
    MOVE: {
      to: STATES.SUSPENDED,
      emission: null,
      outcome: OUTCOMES.INVALID_TRANSITION,
    },
    TERMINATE: {
      to: STATES.SUSPENDED,
      emission: null,
      outcome: OUTCOMES.IDEMPOTENT,
    },
  },
});

const isObject = (value) =>
  value !== null && typeof value === "object" && !Array.isArray(value);

function baseResult(state, event, decidedAt) {
  return {
    employee_id: event.employee_id ?? null,
    event_id: event.event_id ?? null,
    event_type: event.event_type ?? null,
    from: state,
    to: state,
    emission: null,
    decided_at: decidedAt,
  };
}

/**
 * Pure transition. `options.replay` marks an event drained from the parking lot,
 * which reports REPLAYED rather than APPLIED so the audit trail distinguishes
 * "worked first time" from "worked once its precondition finally arrived".
 */
export function applyEvent(state, event, deps = {}, options = {}) {
  if (!isObject(event))
    throw new TypeError("applyEvent(state, event) requires an event object");
  const { clock, taskId = "jml-lifecycle" } = deps;
  if (!clock || typeof clock.now !== "function") {
    throw new TypeError(
      "applyEvent requires deps.clock with now() and newId()",
    );
  }

  const decidedAt = clock.now();
  const from = TRANSITIONS[state] ? state : STATES.NONE;
  const result = baseResult(from, event, decidedAt);
  const row = TRANSITIONS[from][event.event_type];

  if (!row) {
    return {
      ...result,
      ok: false,
      outcome: OUTCOMES.INVALID_TRANSITION,
      detail: `no transition from ${from} for event_type ${String(event.event_type)}`,
    };
  }

  if (row.outcome === OUTCOMES.INVALID_TRANSITION) {
    return {
      ...result,
      ok: false,
      outcome: OUTCOMES.INVALID_TRANSITION,
      to: row.to,
      detail: `${event.event_type} is not a legal transition out of ${from}`,
    };
  }

  if (row.outcome === OUTCOMES.PARKED) {
    return {
      ...result,
      ok: false,
      outcome: OUTCOMES.PARKED,
      to: row.to,
      detail: `${event.event_type} arrived before the account existed; held for replay`,
      fallback: fallbackRecord({
        agent: "lifecycle",
        taskId,
        reason: `event ${event.event_id ?? "unknown"} moves an employee with no provisioned account (state ${from})`,
        missing: [`a HIRE event for ${event.employee_id ?? "this employee"}`],
        how: "hold the event and replay it automatically once the HIRE for this employee is delivered",
        why: "creating an account from a MOVE would invent an identity the HRIS never authorised",
        confidence: 0.25,
      }),
    };
  }

  const applied =
    options.replay === true && row.outcome === OUTCOMES.APPLIED
      ? OUTCOMES.REPLAYED
      : row.outcome;

  return {
    ...result,
    ok: true,
    outcome: applied,
    to: row.to,
    emission: row.emission,
    detail:
      row.emission === null
        ? `${event.event_type} had already taken effect; no IAM call issued`
        : `${from} -> ${row.to} via ${row.emission}`,
  };
}

/**
 * Stateful lifecycle over many employees, with a parking lot.
 *
 * `employees` and `parked` are plain serialisable objects so the CLI can persist
 * them between invocations — which is what makes "PARKED now, REPLAYED after the
 * HIRE arrives" observable across two separate runs rather than only in-process.
 */
export function createLifecycle({
  clock,
  employees = {},
  parked = {},
  taskId = "jml-lifecycle",
} = {}) {
  if (!clock || typeof clock.now !== "function") {
    throw new TypeError(
      "createLifecycle requires an injected clock with now() and newId()",
    );
  }
  const states = { ...employees };
  const parkingLot = {};
  for (const [key, value] of Object.entries(parked))
    parkingLot[key] = [...value];

  const deps = { clock, taskId };

  function stateOf(employeeId) {
    return states[employeeId] ?? STATES.NONE;
  }

  return {
    stateOf,
    /**
     * Apply one event. Returns the primary result plus any parked events that
     * became applicable because of it — a HIRE drains that employee's backlog.
     */
    apply(event) {
      const employeeId = event.employee_id;
      const result = applyEvent(stateOf(employeeId), event, deps);

      if (result.outcome === OUTCOMES.PARKED) {
        parkingLot[employeeId] = [...(parkingLot[employeeId] ?? []), event];
        return { result, replays: [] };
      }

      states[employeeId] = result.to;

      const replays = [];
      if (result.ok && (parkingLot[employeeId] ?? []).length > 0) {
        const queued = parkingLot[employeeId];
        parkingLot[employeeId] = [];
        for (const held of queued) {
          const replayed = applyEvent(stateOf(employeeId), held, deps, {
            replay: true,
          });
          if (replayed.outcome === OUTCOMES.PARKED) {
            parkingLot[employeeId] = [...(parkingLot[employeeId] ?? []), held];
          } else {
            states[employeeId] = replayed.to;
          }
          // Carry the held event itself, not just its verdict: ticketing and
          // notify need the parked payload, and reconstructing it from the
          // event that unblocked it would describe the wrong change.
          replays.push({ result: replayed, event: held });
        }
        if (parkingLot[employeeId].length === 0) delete parkingLot[employeeId];
      }

      return { result, replays };
    },
    parkedFor(employeeId) {
      return [...(parkingLot[employeeId] ?? [])];
    },
    snapshot() {
      return { employees: { ...states }, parked: { ...parkingLot } };
    },
  };
}
