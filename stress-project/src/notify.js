/**
 * (d) Notify — Slack-style chat payload.
 *
 * Nothing is sent anywhere: the payload is built, scrubbed and handed back, and
 * the CLI records that it was emitted. HC-5 leaves no room for a transport, and
 * a mock that pretends to POST would be a worse lie than one that does not.
 *
 * Two rules the scrubber exists to enforce:
 *  - a chat channel is the widest-read surface in the pipeline, so no
 *    secret-shaped key or value may reach it, whatever the upstream fixture put
 *    in the event;
 *  - contact details stay out too. The ticket carries the work email; the
 *    channel gets an employee id, which is enough to act on and cheaper to leak.
 *
 * `findSecretShapes()` returns the offending paths rather than a boolean, so a
 * failing assertion names the field instead of just saying "something leaked".
 */

export const REDACTION = "[redacted]";

/** Key names that carry credentials by convention. */
export const SECRET_KEY_PATTERN =
  /(token|secret|passwd|password|api[-_ ]?key|apikey|authorization|bearer|credential|private[-_ ]?key|access[-_ ]?key)/i;

/** Values that are recognisably credentials whatever they are called. */
export const SECRET_VALUE_PATTERNS = Object.freeze([
  /AKIA[0-9A-Z]{16}/,
  /xox[abprs]-[A-Za-z0-9-]{10,}/,
  /gh[pousr]_[A-Za-z0-9]{20,}/,
  /eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{4,}/,
  /-----BEGIN [A-Z ]*PRIVATE KEY-----/,
]);

const isObject = (value) =>
  value !== null && typeof value === "object" && !Array.isArray(value);

function redactString(value) {
  let out = value;
  for (const pattern of SECRET_VALUE_PATTERNS)
    out = out.replace(new RegExp(pattern, "g"), REDACTION);
  return out;
}

/** Deep copy with secret-shaped keys and values replaced by REDACTION. */
export function scrubSecrets(value) {
  if (typeof value === "string") return redactString(value);
  if (Array.isArray(value)) return value.map(scrubSecrets);
  if (isObject(value)) {
    const out = {};
    for (const [key, inner] of Object.entries(value)) {
      out[key] = SECRET_KEY_PATTERN.test(key) ? REDACTION : scrubSecrets(inner);
    }
    return out;
  }
  return value;
}

/** Paths at which a secret-shaped key or value survives. Empty means clean. */
export function findSecretShapes(value, path = "$") {
  const found = [];
  if (typeof value === "string") {
    if (
      value !== REDACTION &&
      SECRET_VALUE_PATTERNS.some((pattern) => pattern.test(value))
    ) {
      found.push({ path, why: "value matches a credential shape" });
    }
    return found;
  }
  if (Array.isArray(value)) {
    value.forEach((item, index) =>
      found.push(...findSecretShapes(item, `${path}[${index}]`)),
    );
    return found;
  }
  if (isObject(value)) {
    for (const [key, inner] of Object.entries(value)) {
      const next = `${path}.${key}`;
      if (SECRET_KEY_PATTERN.test(key) && inner !== REDACTION) {
        found.push({ path: next, why: "key name is credential-shaped" });
        continue;
      }
      found.push(...findSecretShapes(inner, next));
    }
  }
  return found;
}

/**
 * Build the chat payload for a completed (or failed) lifecycle action.
 * The whole payload passes through the scrubber on the way out — including the
 * parts we assembled ourselves, because "our own fields are safe" is exactly the
 * assumption that lets a fixture-sourced value ride along inside one of them.
 */
export function buildNotification(
  { event = {}, lifecycle = {}, ticket = {}, iam = {} },
  { clock, channel = "#it-identity" } = {},
) {
  if (!clock || typeof clock.now !== "function") {
    throw new TypeError(
      "buildNotification requires an injected clock with now() and newId()",
    );
  }

  const failed = iam.ok === false;
  const employeeId = event.employee_id ?? lifecycle.employee_id ?? "unknown";
  const displayName = event.employee?.display_name ?? employeeId;
  const department = event.department?.name ?? "unassigned";
  const action = lifecycle.emission ?? "none";
  const heading = failed
    ? "Identity action FAILED"
    : "Identity action completed";

  const payload = {
    channel,
    username: "jml-simulator",
    text: `${heading}: ${event.event_type ?? "EVENT"} for ${employeeId} (${action})`,
    notification_id: clock.newId("ntf"),
    sent_at: clock.now(),
    blocks: [
      { type: "header", text: { type: "plain_text", text: heading } },
      {
        type: "section",
        fields: [
          {
            type: "mrkdwn",
            text: `*Employee*\n${displayName} (${employeeId})`,
          },
          { type: "mrkdwn", text: `*Event*\n${event.event_type ?? "unknown"}` },
          { type: "mrkdwn", text: `*Department*\n${department}` },
          { type: "mrkdwn", text: `*IAM action*\n${action}` },
        ],
      },
      {
        type: "context",
        elements: [
          {
            type: "mrkdwn",
            text: failed
              ? `Ticket ${ticket.key ?? "n/a"} opened at highest priority - ${iam.error?.code ?? "UNKNOWN"}`
              : `Ticket ${ticket.key ?? "n/a"} - ${lifecycle.from ?? "NONE"} to ${lifecycle.to ?? "NONE"}`,
          },
        ],
      },
    ],
  };

  return scrubSecrets(payload);
}
