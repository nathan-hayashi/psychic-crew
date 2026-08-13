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

import { iamFailed } from "./adapters/iam.js";

export const REDACTION = "[redacted]";

/** Longest webhook-sourced free-text run allowed into one rendered field. */
export const MRKDWN_FIELD_LIMIT = 120;

/**
 * Render one piece of webhook-controlled free text as mrkdwn body copy.
 *
 * `validateEvent()` checks four fields for non-emptiness and `display_name` is
 * not one of them, `normaliseString()` collapses whitespace without touching
 * markup, and `scrubSecrets()` matches credential shapes only — so nothing on
 * the path between the HRIS and a rendered block escapes anything. A display
 * name of `*IT Operations*` renders as a formatted heading, and one carrying
 * `<https://elsewhere|click here>` renders as a link the desk did not write.
 *
 * Slack's three reserved characters are escaped, its formatting characters are
 * stripped (rather than backslash-escaped, which mrkdwn does not honour), and
 * the result is capped — a field is a label, not a document.
 */
export function mrkdwnText(value) {
  return (
    String(value ?? "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      // A SPACE, not an empty string: deleting the pipe out of a link payload
      // welds its two halves into one word ("invalidclick here"), which is a
      // second way of rendering something the desk did not write. Whitespace is
      // collapsed and trimmed immediately below, so `*Nils Baird*` still reads
      // `Nils Baird` rather than gaining padding.
      .replace(/[*_~`|]/g, " ")
      .replace(/\s+/g, " ")
      .trim()
      .slice(0, MRKDWN_FIELD_LIMIT)
  );
}

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

  // One shared predicate, no local exemption: a failed suspend is a failure
  // here for exactly the same reason it is one on the ticket.
  const failed = iamFailed(iam);
  const employeeId = event.employee_id ?? lifecycle.employee_id ?? "unknown";
  const displayName = mrkdwnText(event.employee?.display_name ?? employeeId);
  const department = mrkdwnText(event.department?.name ?? "unassigned");
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
          {
            type: "mrkdwn",
            text: `*Event*\n${mrkdwnText(event.event_type ?? "unknown")}`,
          },
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
