/**
 * (c) Ticketing tests — the Jira-shaped issue, on both the success and the
 * failure path.
 *
 * The failure case carries its own success control. Without it, "status is
 * Failed" could pass because the builder always says Failed, and the assertion
 * would measure nothing.
 */

import { test } from "node:test";
import assert from "node:assert/strict";

import { fixedClock } from "../src/adapters/clock.js";
import { IAM_ACTIONS, createIamAdapter } from "../src/adapters/iam.js";
import { STATES, applyEvent } from "../src/lifecycle.js";
import { REDACTION, findSecretShapes } from "../src/notify.js";
import {
  PROJECT_KEY,
  TICKET_PRIORITY,
  TICKET_STATUS,
  buildTicket,
  ticketKey,
} from "../src/ticketing.js";

/** The system fields a Jira create-issue body is expected to carry. */
const JIRA_FIELDS = [
  "project",
  "issuetype",
  "summary",
  "description",
  "status",
  "priority",
  "labels",
  "reporter",
  "assignee",
  "duedate",
  "created",
  "customfield_employee_id",
  "customfield_event_id",
  "customfield_iam_action",
  "customfield_iam_request_id",
  "customfield_iam_error_code",
];

const clock = (seed) =>
  fixedClock({ startedAt: "2026-03-01T00:00:00.000Z", seed });

const terminateEvent = {
  event_id: "evt_test-terminate-0001",
  event_type: "TERMINATE",
  occurred_at: "2026-03-01T09:00:00.000Z",
  effective_date: "2026-03-15",
  employee_id: "EMP-90003",
  employee: { display_name: "Ines Farkas" },
  department: { id: "DEP-DATA", name: "Data and Analytics" },
  entitlements: { grant: [], revoke: ["idp.baseline", "vpn.standard"] },
};

test("ticket-shape-matches-jira-fields", () => {
  const c = clock("ticket-shape");
  const lifecycle = applyEvent(STATES.ACTIVE, terminateEvent, { clock: c });
  const iam = createIamAdapter({ clock: c }).apply({
    action: lifecycle.emission,
    employeeId: terminateEvent.employee_id,
    event: terminateEvent,
  });
  const ticket = buildTicket(
    { event: terminateEvent, lifecycle, iam, sequence: 1 },
    { clock: c },
  );

  assert.equal(ticket.key, "JML-0001");
  assert.match(ticket.key, /^JML-\d{4}$/);
  assert.equal(ticket.self, "jml://tickets/JML-0001");
  assert.equal(ticketKey(42), "JML-0042", "sequence is zero-padded to four");

  assert.deepEqual(
    Object.keys(ticket.fields).sort(),
    [...JIRA_FIELDS].sort(),
    "exact field set: a renamed or dropped system field must fail by name",
  );

  assert.deepEqual(ticket.fields.project, {
    key: PROJECT_KEY,
    name: "Joiner Mover Leaver",
  });
  assert.deepEqual(ticket.fields.issuetype, { name: "Service Request" });
  assert.equal(
    ticket.fields.summary,
    "TERMINATE: suspend access for Ines Farkas (EMP-90003)",
  );
  assert.deepEqual(ticket.fields.status, { name: TICKET_STATUS.DONE });
  assert.deepEqual(ticket.fields.priority, { name: TICKET_PRIORITY.NORMAL });
  assert.deepEqual(ticket.fields.labels, [
    "identity-lifecycle",
    "event-terminate",
    "action-suspend",
  ]);
  assert.deepEqual(ticket.fields.reporter, { name: "hris-integration" });
  assert.deepEqual(ticket.fields.assignee, { name: "iam-operations" });
  assert.equal(ticket.fields.duedate, "2026-03-15");
  assert.equal(ticket.fields.customfield_employee_id, "EMP-90003");
  assert.equal(ticket.fields.customfield_event_id, "evt_test-terminate-0001");
  assert.equal(ticket.fields.customfield_iam_action, IAM_ACTIONS.SUSPEND);
  assert.equal(ticket.fields.customfield_iam_request_id, iam.request_id);
  assert.equal(ticket.fields.customfield_iam_error_code, null);
  // Third clock tick: applyEvent, then iam.apply, then buildTicket.
  assert.equal(ticket.fields.created, "2026-03-01T00:00:02.000Z");
  assert.match(ticket.fields.description, /ACTIVE -> SUSPENDED \(APPLIED\)/);

  // The ticket is the DURABLE artifact and its own docstring says a client
  // could POST it unchanged, so it owes the same scrubbing the chat payload
  // gets. The token is planted in a field the builder actually copies, and the
  // control below proves the detector can see it unscrubbed — without that,
  // an always-empty findSecretShapes() would satisfy the assertion.
  const planted = ["AKIA", "ABCDEFGHIJKLMNOP"].join("");
  const leaky = {
    ...terminateEvent,
    employee: { display_name: `Ines Farkas ${planted}` },
  };
  assert.equal(findSecretShapes(leaky).length, 1);
  assert.equal(findSecretShapes(leaky)[0].path, "$.employee.display_name");

  const leakyTicket = buildTicket(
    { event: leaky, lifecycle, iam, sequence: 9 },
    { clock: clock("ticket-scrub") },
  );
  assert.deepEqual(
    findSecretShapes(leakyTicket),
    [],
    "a credential must not survive into a ticket written to disk and POSTed",
  );
  assert.equal(JSON.stringify(leakyTicket).includes(planted), false);
  assert.equal(
    JSON.stringify(leakyTicket).includes(REDACTION),
    true,
    "it must be redacted, not silently dropped",
  );
});

test("iam-adapter-failure-produces-failed-ticket", () => {
  const c = clock("ticket-failure");
  const adapter = createIamAdapter({ clock: c, failOn: ["suspend"] });
  const lifecycle = applyEvent(STATES.ACTIVE, terminateEvent, { clock: c });
  const iam = adapter.apply({
    action: lifecycle.emission,
    employeeId: terminateEvent.employee_id,
    event: terminateEvent,
  });

  assert.equal(iam.ok, false, "failOn must actually fail the suspend");
  assert.equal(iam.error.code, "IAM_UPSTREAM_UNAVAILABLE");
  assert.equal(iam.error.retryable, true);
  assert.equal(adapter.calls.length, 1);
  assert.equal(adapter.calls[0].ok, false);

  const ticket = buildTicket(
    { event: terminateEvent, lifecycle, iam, sequence: 2 },
    { clock: c },
  );

  assert.equal(ticket.key, "JML-0002");
  assert.deepEqual(ticket.fields.status, { name: TICKET_STATUS.FAILED });
  assert.deepEqual(ticket.fields.priority, { name: TICKET_PRIORITY.URGENT });
  assert.ok(
    ticket.fields.labels.includes("iam-failure"),
    "the failure must be visible as a label, not only in prose",
  );
  assert.deepEqual(ticket.fields.assignee, { name: "iam-oncall" });
  assert.equal(
    ticket.fields.customfield_iam_error_code,
    "IAM_UPSTREAM_UNAVAILABLE",
  );
  assert.equal(ticket.fields.customfield_iam_request_id, iam.request_id);
  assert.match(ticket.fields.description, /IAM iam\.suspend FAILED/);
  assert.match(ticket.fields.description, /Retryable: true/);

  // Control: the same builder on a working adapter must NOT say Failed.
  const okClock = clock("ticket-failure-control");
  const okIam = createIamAdapter({ clock: okClock }).apply({
    action: IAM_ACTIONS.SUSPEND,
    employeeId: terminateEvent.employee_id,
    event: terminateEvent,
  });
  const okTicket = buildTicket(
    { event: terminateEvent, lifecycle, iam: okIam, sequence: 3 },
    { clock: okClock },
  );
  assert.equal(okIam.ok, true);
  assert.deepEqual(okTicket.fields.status, { name: TICKET_STATUS.DONE });
  assert.equal(okTicket.fields.labels.includes("iam-failure"), false);
  assert.equal(okTicket.fields.customfield_iam_error_code, null);
});
