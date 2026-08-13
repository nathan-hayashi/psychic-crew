/**
 * (d) Notify test — the chat payload's structure, and what must never be in it.
 *
 * The event deliberately carries a credential-shaped value inside a field the
 * builder DOES copy (display_name), so the scrubber is on the path. A clean
 * fixture would make the "no secrets" assertion vacuous: it would pass on a
 * build with the scrubber deleted.
 */

import { test } from "node:test";
import assert from "node:assert/strict";

import { fixedClock } from "../src/adapters/clock.js";
import { IAM_ACTIONS } from "../src/adapters/iam.js";
import {
  REDACTION,
  buildNotification,
  findSecretShapes,
} from "../src/notify.js";

// A Slack-shaped bot token. Fake, and never a real credential — its only job is
// to be recognisable to SECRET_VALUE_PATTERNS.
// Assembled from fragments, never stored contiguously. ERR6 (F6 corpus) scans TRACKED files for
// token shapes because this repo is public, and a committed literal is exactly what GitHub secret
// scanning flags — the guard caught this file before it was pushed. The test needs a genuine token
// SHAPE at runtime, so build it here: no tracked byte matches the pattern, the assertion is
// unchanged, and findSecretShapes still receives a real Slack-shaped bot token.
const PLANTED_TOKEN = ["xoxb", "2451234567890", "abcDEF123456"].join("-");
const WORK_EMAIL = "nils.baird@example.invalid";

test("slack-payload-has-blocks-and-no-secret-shaped-fields", () => {
  const clock = fixedClock({
    startedAt: "2026-04-01T00:00:00.000Z",
    seed: "notify-suite",
  });

  const event = {
    event_id: "evt_test-move-0001",
    event_type: "MOVE",
    employee_id: "EMP-90004",
    employee: {
      display_name: `Nils Baird ${PLANTED_TOKEN}`,
      work_email: WORK_EMAIL,
    },
    department: { id: "DEP-OPS", name: "IT Operations" },
  };
  const lifecycle = {
    employee_id: "EMP-90004",
    from: "ACTIVE",
    to: "ACTIVE",
    outcome: "APPLIED",
    emission: IAM_ACTIONS.TRANSFER,
  };

  // Control: the detector can see the planted token when it is not scrubbed.
  // Without this, an always-empty findSecretShapes() would satisfy the case.
  assert.equal(findSecretShapes(event).length, 1);
  assert.equal(findSecretShapes(event)[0].path, "$.employee.display_name");

  const payload = buildNotification(
    { event, lifecycle, ticket: { key: "JML-0007" }, iam: { ok: true } },
    { clock },
  );

  assert.deepEqual(
    findSecretShapes(payload),
    [],
    "no credential-shaped key or value may reach a chat channel",
  );
  const serialised = JSON.stringify(payload);
  assert.equal(
    serialised.includes(PLANTED_TOKEN),
    false,
    "the planted token must not survive anywhere in the payload",
  );
  assert.ok(serialised.includes(REDACTION), "it must be redacted, not dropped");
  assert.equal(
    serialised.includes(WORK_EMAIL),
    false,
    "contact details stay out of the channel; the employee id is enough to act on",
  );

  assert.equal(payload.channel, "#it-identity");
  assert.equal(payload.username, "jml-simulator");
  assert.equal(
    payload.text,
    "Identity action completed: MOVE for EMP-90004 (iam.transfer)",
  );
  // Seeded id: a pure function of (seed, prefix, call-index), so it is a
  // constant here. Asserting the literal is what makes a rerun byte-identical
  // rather than merely well-shaped.
  assert.equal(payload.notification_id, "ntf_991cf3a1dc52");
  assert.equal(payload.sent_at, "2026-04-01T00:00:00.000Z");

  assert.ok(Array.isArray(payload.blocks));
  assert.equal(payload.blocks.length, 3);
  assert.deepEqual(
    payload.blocks.map((block) => block.type),
    ["header", "section", "context"],
  );
  assert.deepEqual(payload.blocks[0].text, {
    type: "plain_text",
    text: "Identity action completed",
  });
  assert.equal(payload.blocks[1].fields.length, 4);
  assert.deepEqual(
    payload.blocks[1].fields.map((field) => field.type),
    ["mrkdwn", "mrkdwn", "mrkdwn", "mrkdwn"],
  );
  assert.match(payload.blocks[1].fields[0].text, /\*Employee\*/);
  assert.match(payload.blocks[1].fields[0].text, /\(EMP-90004\)/);
  assert.match(payload.blocks[1].fields[2].text, /IT Operations/);
  assert.match(payload.blocks[2].elements[0].text, /JML-0007/);

  // ---- the failure branch, which nothing exercised before (F7-QUAL-03) ----
  // The suspend action is named on purpose: the exemption this asserts against
  // was carved out for `iam.suspend` alone, so any other action would pass on
  // the defective build and measure nothing.
  const failedPayload = buildNotification(
    {
      event: { ...event, event_type: "TERMINATE" },
      lifecycle: {
        ...lifecycle,
        to: "SUSPENDED",
        emission: IAM_ACTIONS.SUSPEND,
      },
      ticket: { key: "JML-0008" },
      iam: {
        ok: false,
        action: IAM_ACTIONS.SUSPEND,
        error: { code: "IAM_UPSTREAM_UNAVAILABLE", retryable: true },
      },
    },
    { clock },
  );

  assert.equal(
    failedPayload.text,
    "Identity action FAILED: TERMINATE for EMP-90004 (iam.suspend)",
    "a failed suspend must read as FAILED in chat, exactly as it does on the ticket",
  );
  assert.deepEqual(failedPayload.blocks[0].text, {
    type: "plain_text",
    text: "Identity action FAILED",
  });
  assert.match(
    failedPayload.blocks[2].elements[0].text,
    /highest priority - IAM_UPSTREAM_UNAVAILABLE/,
  );

  // ---- webhook free text may not carry markup into a rendered block (sec-4) ----
  const injected = buildNotification(
    {
      event: {
        ...event,
        employee: {
          display_name: "*Nils Baird* <https://elsewhere.invalid|click here>",
        },
        department: { name: "IT `Operations`" },
      },
      lifecycle,
      ticket: { key: "JML-0009" },
      iam: { ok: true },
    },
    { clock },
  );

  const employeeField = injected.blocks[1].fields[0].text;
  const departmentField = injected.blocks[1].fields[2].text;
  assert.equal(
    employeeField,
    "*Employee*\nNils Baird &lt;https://elsewhere.invalid click here&gt; (EMP-90004)",
    "our own label keeps its markup; the webhook's does not",
  );
  assert.equal(departmentField, "*Department*\nIT Operations");
});
