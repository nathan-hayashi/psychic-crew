/*
 * router.test.js — every status this server can produce, with no port bound.
 *
 * These six cases talk to route() directly. Nothing here opens a socket, so a
 * red line in this file means the decision is wrong, not that the transport
 * is. test/server.test.js proves the other half separately, and keeping the
 * two apart is what stops a routing bug and a transport bug from taking turns
 * hiding behind each other.
 */

import assert from "node:assert/strict";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { test } from "node:test";

import { route } from "../src/router.js";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..", "public");

test("root-path-serves-index-html", () => {
  const decision = route("GET", "/", ROOT);
  assert.equal(decision.status, 200);
  assert.ok(
    decision.filePath.endsWith(join("public", "index.html")),
    "root resolved to " + decision.filePath,
  );
  assert.equal(decision.headers["content-type"], "text/html; charset=utf-8");
});

test("privacy-path-serves-privacy-html", () => {
  const decision = route("GET", "/privacy.html", ROOT);
  assert.equal(decision.status, 200);
  assert.ok(
    decision.filePath.endsWith(join("public", "privacy.html")),
    "privacy resolved to " + decision.filePath,
  );
  assert.equal(decision.headers["content-type"], "text/html; charset=utf-8");
});

test("unknown-path-returns-404-with-a-body", () => {
  const decision = route("GET", "/no-such-page.html", ROOT);
  assert.equal(decision.status, 404);
  assert.equal(decision.filePath, null);
  assert.ok(decision.body.length > 0, "a 404 with an empty body tells the reader nothing");
  // The body must not quote the request back: a reflected path is a surface
  // that costs nothing to simply not have.
  assert.ok(!decision.body.includes("no-such-page"), "the 404 body reflects the request");
});

test("post-to-a-static-path-returns-405-and-an-allow-header", () => {
  const decision = route("POST", "/", ROOT);
  assert.equal(decision.status, 405);
  assert.equal(decision.headers.allow, "GET, HEAD");
  // The method is answered before the path is examined, so a disallowed verb
  // on a refused path is still a 405 and never confirms that we looked.
  assert.equal(route("POST", "/../package.json", ROOT).status, 405);
});

test("query-string-does-not-change-the-resolved-file", () => {
  const plain = route("GET", "/", ROOT);
  const queried = route("GET", "/?utm_source=a&utm_campaign=b", ROOT);
  const fragmented = route("GET", "/privacy.html#retention", ROOT);
  assert.equal(queried.status, 200);
  assert.equal(queried.filePath, plain.filePath);
  assert.equal(fragmented.status, 200);
  assert.equal(fragmented.filePath, route("GET", "/privacy.html", ROOT).filePath);
});

test("plain-dot-dot-traversal-is-refused", () => {
  const decision = route("GET", "/../package.json", ROOT);
  assert.equal(decision.status, 400);
  assert.equal(decision.filePath, null);
  // Refused, not merely missing: package.json is genuinely there one level up,
  // so a 404 here would mean the fence had let the lookup happen at all.
  assert.equal(route("GET", "/../../etc/passwd", ROOT).status, 400);
  assert.equal(route("GET", "/subdir/../../package.json", ROOT).status, 400);
});
