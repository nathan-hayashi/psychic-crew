/*
 * router.test.js — every status this server can produce, with no port bound.
 *
 * These seven cases talk to route() directly. Nothing here opens a socket, so a
 * red line in this file means the decision is wrong, not that the transport
 * is. test/server.test.js proves the other half separately, and keeping the
 * two apart is what stops a routing bug and a transport bug from taking turns
 * hiding behind each other.
 */

import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
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

// A scratch tree the fence can be aimed at, built outside the repository: a
// served root, a sibling directory that is NOT inside it, and the two shapes of
// link between them. Returns everything the case needs to clean up after
// itself.
function buildSymlinkTree() {
  const scratch = mkdtempSync(join(tmpdir(), "stress-site-symlink-"));
  const root = join(scratch, "root");
  const outside = join(scratch, "outside");
  mkdirSync(root);
  mkdirSync(outside);
  writeFileSync(join(outside, "secret.txt"), SECRET, "utf8");
  writeFileSync(join(root, "real.txt"), "an ordinary file, genuinely inside\n", "utf8");
  // Shape 1: the link is the last component of the request path.
  symlinkSync(join(outside, "secret.txt"), join(root, "leak.txt"));
  // Shape 2: the link is a DIRECTORY in the middle of the request path. This is
  // the shape a final-component lstat check cannot see, which is why it is here.
  symlinkSync(outside, join(root, "away"));
  // Shape 3: a link that stays inside. Confinement is about where a link lands,
  // not about links being forbidden, so this one must still be served.
  symlinkSync(join(root, "real.txt"), join(root, "alias.txt"));
  return { scratch, root };
}

const SECRET = "SENTINEL-OUTSIDE-THE-ROOT\n";

test("symlink-escaping-the-root-is-refused-and-one-staying-inside-is-served", () => {
  const { scratch, root } = buildSymlinkTree();
  try {
    // Control first: if this is not 200, the rest of the case proves nothing,
    // because every 404 below could be an unrelated broken resolver.
    assert.equal(route("GET", "/real.txt", root).status, 200, "the ordinary control file was not served");

    for (const escape of ["/leak.txt", "/away/secret.txt"]) {
      const decision = route("GET", escape, root);
      assert.equal(
        decision.filePath,
        null,
        escape + " resolved to " + decision.filePath + ", which is outside the root",
      );
      assert.equal(decision.status, 404, escape + " was served with status " + decision.status);
      // Bind to the bytes, not just the status: this is the observable
      // consequence the finding describes.
      assert.ok(
        decision.body === null || !decision.body.includes("SENTINEL"),
        escape + " leaked the outside file into the response body",
      );
    }

    // The precision half: containment refuses links that LEAVE, not links.
    const inside = route("GET", "/alias.txt", root);
    assert.equal(inside.status, 200, "a symlink pointing inside the root was refused as well");
    assert.ok(
      readFileSync(inside.filePath, "utf8").includes("genuinely inside"),
      "the inside-root link served the wrong bytes",
    );
  } finally {
    rmSync(scratch, { recursive: true, force: true });
  }
});
