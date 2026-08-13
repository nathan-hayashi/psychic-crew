/**
 * (c) Ticketing — Jira-style issue JSON for the service desk.
 *
 * A ticket is the durable record a human can act on, so it is written for work
 * that actually touched the identity provider: an applied or replayed event, or
 * an event whose IAM call failed. Idempotent no-ops and parked events do not
 * open tickets — a queue full of "nothing happened" issues is how real desks
 * learn to ignore the queue.
 *
 * The failure path is deliberately a first-class shape, not an exception. When
 * the injected IAM adapter fails, the ticket still exists, carries the provider
 * error code, and is marked Failed at the highest priority.
 */

import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";

export const PROJECT_KEY = "JML";

export const TICKET_STATUS = Object.freeze({ DONE: "Done", FAILED: "Failed" });
export const TICKET_PRIORITY = Object.freeze({
  NORMAL: "Medium",
  URGENT: "Highest",
});

const ACTION_LABEL = Object.freeze({
  "iam.create": "provision",
  "iam.transfer": "transfer",
  "iam.suspend": "suspend",
});

/** A ticket is warranted only when the IAM provider was actually engaged. */
export function shouldOpenTicket(lifecycleResult) {
  return Boolean(lifecycleResult) && lifecycleResult.emission !== null;
}

export function ticketKey(sequence) {
  return `${PROJECT_KEY}-${String(sequence).padStart(4, "0")}`;
}

/**
 * Build the issue. Shape mirrors the Jira REST create-issue body: a `key` plus a
 * `fields` object whose members are the named system fields, so a downstream
 * client could POST it unchanged.
 */
export function buildTicket(
  { event = {}, lifecycle = {}, iam = {}, sequence = 1 },
  { clock } = {},
) {
  if (!clock || typeof clock.now !== "function") {
    throw new TypeError(
      "buildTicket requires an injected clock with now() and newId()",
    );
  }

  const failed = iam.ok === false;
  const action = lifecycle.emission ?? iam.action ?? null;
  const verb = ACTION_LABEL[action] ?? "update";
  const employeeId = event.employee_id ?? lifecycle.employee_id ?? "unknown";
  const displayName = event.employee?.display_name ?? employeeId;
  const department = event.department?.name ?? "unassigned";

  const labels = [
    "identity-lifecycle",
    `event-${String(event.event_type ?? "unknown").toLowerCase()}`,
    `action-${verb}`,
  ];
  if (failed) labels.push("iam-failure");
  if (lifecycle.outcome === "REPLAYED") labels.push("replayed-after-park");

  const descriptionLines = [
    `Event ${event.event_id ?? "unknown"} (${event.event_type ?? "unknown"}) for ${displayName} [${employeeId}].`,
    `Lifecycle: ${lifecycle.from ?? "NONE"} -> ${lifecycle.to ?? "NONE"} (${lifecycle.outcome ?? "UNKNOWN"}).`,
    `Department: ${department}. Effective ${event.effective_date ?? "unspecified"}.`,
    failed
      ? `IAM ${action} FAILED: ${iam.error?.code ?? "UNKNOWN"} - ${iam.error?.message ?? "no message"}. Retryable: ${iam.error?.retryable ?? false}.`
      : `IAM ${action} succeeded, provider ref ${iam.provider_ref ?? "n/a"}.`,
  ];

  return {
    key: ticketKey(sequence),
    self: `jml://tickets/${ticketKey(sequence)}`,
    fields: {
      project: { key: PROJECT_KEY, name: "Joiner Mover Leaver" },
      issuetype: { name: "Service Request" },
      summary: `${String(event.event_type ?? "EVENT").toUpperCase()}: ${verb} access for ${displayName} (${employeeId})`,
      description: descriptionLines.join("\n"),
      status: { name: failed ? TICKET_STATUS.FAILED : TICKET_STATUS.DONE },
      priority: {
        name: failed ? TICKET_PRIORITY.URGENT : TICKET_PRIORITY.NORMAL,
      },
      labels,
      reporter: { name: "hris-integration" },
      assignee: { name: failed ? "iam-oncall" : "iam-operations" },
      duedate: event.effective_date ?? null,
      created: clock.now(),
      customfield_employee_id: employeeId,
      customfield_event_id: event.event_id ?? null,
      customfield_iam_action: action,
      customfield_iam_request_id: iam.request_id ?? null,
      customfield_iam_error_code: failed
        ? (iam.error?.code ?? "UNKNOWN")
        : null,
    },
  };
}

/** Persist the ticket under `dir`. Runtime output only — D2 keeps this in tmp/. */
export function writeTicket(ticket, dir) {
  mkdirSync(dir, { recursive: true });
  const path = join(dir, `${ticket.key}.json`);
  writeFileSync(path, `${JSON.stringify(ticket, null, 2)}\n`, "utf8");
  return path;
}
