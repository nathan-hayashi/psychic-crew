/**
 * Mock IAM adapter with injectable failure.
 *
 * Stands in for the identity provider: create an account, transfer it between
 * departments, suspend it. Nothing leaves the process — there is no network
 * here and there will not be one (HC-5).
 *
 * The failure injection is the point. A provider that always succeeds cannot
 * exercise the failed-ticket path, so `failOn` lets a caller name the actions
 * that must fail. It accepts either a list of action names or a predicate, so a
 * test can fail one specific employee's transfer without failing every transfer.
 */

export const IAM_ACTIONS = Object.freeze({
  CREATE: "iam.create",
  TRANSFER: "iam.transfer",
  SUSPEND: "iam.suspend",
});

const KNOWN_ACTIONS = new Set(Object.values(IAM_ACTIONS));

/**
 * "Did the downstream IAM call fail" — asked in four places (ticketing, notify
 * and twice in the CLI), so it is answered in ONE. It used to be reimplemented
 * per caller, and one copy grew an `action !== "iam.suspend"` exemption the
 * others never had: a failed termination was reported to chat as completed
 * while the ticket said Failed. Duplicated predicates do not merely risk
 * drifting; nothing here could ever have reported that they had.
 */
export function iamFailed(result) {
  return result?.ok === false;
}

/**
 * A failure the provider itself says may be re-attempted. This is the ONLY
 * reader of `error.retryable`, and it exists because the field was previously
 * printed to a human on every Failed ticket while no code path consulted it —
 * an instruction the pipeline could not honour. Intake's outcome-aware dedupe
 * calls this to decide whether a redelivery is a RETRY or a DUPLICATE.
 */
export function iamRetryable(result) {
  return iamFailed(result) && result?.error?.retryable === true;
}

/** `create`, `iam.create` and `all` all select the create action. */
function normaliseSelector(selector) {
  const value = String(selector).trim().toLowerCase();
  if (value === "all" || value === "*") return "all";
  return value.startsWith("iam.") ? value : `iam.${value}`;
}

export function createIamAdapter({
  clock,
  failOn = [],
  errorCode = "IAM_UPSTREAM_UNAVAILABLE",
} = {}) {
  if (
    !clock ||
    typeof clock.now !== "function" ||
    typeof clock.newId !== "function"
  ) {
    throw new TypeError(
      "createIamAdapter requires an injected clock with now() and newId()",
    );
  }

  const predicate =
    typeof failOn === "function"
      ? failOn
      : (() => {
          const selectors = new Set(
            (Array.isArray(failOn) ? failOn : [failOn])
              .filter(Boolean)
              .map(normaliseSelector),
          );
          return (action) => selectors.has("all") || selectors.has(action);
        })();

  const calls = [];

  return {
    /** Every call made, success or failure — the ticketing tests assert on it. */
    calls,
    apply({ action, employeeId, event = {} } = {}) {
      if (!KNOWN_ACTIONS.has(action)) {
        // Programmer error: the lifecycle module chose an emission this adapter
        // does not implement. That is a bug in our code, not a domain outcome.
        throw new TypeError(`unsupported IAM action: ${String(action)}`);
      }

      const attemptedAt = clock.now();
      const requestId = clock.newId("iam");
      const grant = event?.entitlements?.grant ?? [];
      const revoke = event?.entitlements?.revoke ?? [];

      if (predicate(action, { employeeId, event })) {
        const failure = {
          ok: false,
          action,
          employee_id: employeeId ?? null,
          request_id: requestId,
          attempted_at: attemptedAt,
          error: {
            code: errorCode,
            message: `IAM provider rejected ${action} for ${employeeId ?? "unknown employee"}`,
            retryable: true,
          },
        };
        calls.push(failure);
        return failure;
      }

      const success = {
        ok: true,
        action,
        employee_id: employeeId ?? null,
        request_id: requestId,
        applied_at: attemptedAt,
        provider_ref: `idp:${clock.newId("acct")}`,
        entitlements: { granted: [...grant], revoked: [...revoke] },
      };
      calls.push(success);
      return success;
    },
  };
}
