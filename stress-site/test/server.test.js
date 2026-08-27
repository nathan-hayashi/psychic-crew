/*
 * server.test.js — the transport half, against a server that is really running.
 *
 * The port is 0 in the one place it is chosen, and every request is aimed at
 * the port the operating system actually handed back. Nothing here reads a
 * fixed number, so two of these suites can run at once, on any machine,
 * without a port registry and without the flake that a fixed port guarantees
 * the first time something else is already holding it.
 *
 * Three of the five cases carry the edge- prefix. They are the ones that are
 * about the server surviving something rather than answering something.
 */

import assert from "node:assert/strict";
import { once } from "node:events";
import { readFileSync, statSync } from "node:fs";
import { request } from "node:http";
import { connect } from "node:net";
import { dirname, join } from "node:path";
import { after, before, test } from "node:test";
import { fileURLToPath } from "node:url";

import { LOOPBACK_HOST, close, createSiteServer, listen } from "../src/server.js";

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = join(HERE, "..", "public");
const REQUESTED_PORT = 0;

let server;
let bound;

before(async () => {
  server = createSiteServer(ROOT);
  bound = await listen(server, REQUESTED_PORT);
});

after(async () => {
  await close(server);
});

function fetchPath(path, method = "GET") {
  return new Promise((settle, fail) => {
    const call = request(
      { host: LOOPBACK_HOST, port: bound.port, path, method },
      (response) => {
        const chunks = [];
        response.on("data", (chunk) => chunks.push(chunk));
        response.on("end", () =>
          settle({
            status: response.statusCode,
            headers: response.headers,
            body: Buffer.concat(chunks),
          }),
        );
      },
    );
    call.on("error", fail);
    call.end();
  });
}

// Open a connection, say part of something, and leave. Returns once the socket
// is gone, so the case that follows is a state check rather than a race.
async function abandonRequest(text) {
  const socket = connect(bound.port, LOOPBACK_HOST);
  socket.on("error", () => {});
  await once(socket, "connect");
  socket.write(text);
  socket.destroy();
  await once(socket, "close");
}

test("server-binds-loopback-and-reports-its-bound-port", () => {
  assert.equal(bound.host, "127.0.0.1");
  assert.equal(server.address().address, "127.0.0.1");
  // The reported port must be the one that was bound, never the one requested.
  assert.equal(REQUESTED_PORT, 0);
  assert.ok(bound.port > 0, "reported port was " + bound.port);
  assert.equal(bound.port, server.address().port);
  assert.equal(bound.url, "http://127.0.0.1:" + bound.port + "/");
});

test("two-identical-gets-return-byte-identical-bodies", async () => {
  const first = await fetchPath("/");
  const second = await fetchPath("/");
  assert.equal(first.status, 200);
  assert.equal(second.status, 200);
  assert.ok(first.body.length > 0, "the first response had an empty body");
  assert.ok(first.body.equals(second.body), "two GETs of / differed byte for byte");
  assert.ok(
    first.body.equals(readFileSync(join(ROOT, "index.html"))),
    "the served bytes differ from the file on disk",
  );
});

test("edge-percent-encoded-traversal-is-refused", async () => {
  const response = await fetchPath("/%2e%2e/package.json");
  assert.equal(response.status, 400);
  // The refusal has to mean something: the file it aimed at genuinely exists
  // one level up, so a 400 here is the fence holding, not a lucky miss.
  assert.ok(
    statSync(join(ROOT, "..", "package.json")).isFile(),
    "the traversal target does not exist, so this case proves nothing",
  );
  assert.ok(!response.body.includes("stress-site"), "the refusal leaked file contents");
  // Encoded twice is a literal file name, not a second chance at traversal.
  assert.equal((await fetchPath("/%252e%252e/package.json")).status, 404);
});

test("edge-head-returns-headers-and-an-empty-body", async () => {
  const head = await fetchPath("/", "HEAD");
  const get = await fetchPath("/");
  assert.equal(head.status, 200);
  assert.equal(head.headers["content-type"], "text/html; charset=utf-8");
  assert.equal(head.body.length, 0, "HEAD returned " + head.body.length + " bytes of body");
  assert.equal(
    head.headers["content-length"],
    String(get.body.length),
    "HEAD must describe the body it is not sending",
  );
});

test("edge-aborted-request-does-not-kill-the-server", async () => {
  await abandonRequest("GET /index.html HTTP/1.1\r\nHost: 127.0.0.1\r\n\r\n");
  await abandonRequest("GET /index.html HTTP/1.1\r\nHost: 127.0");
  await abandonRequest("not a request at all");
  // A state check, not a timing check: the question is whether the process is
  // still serving afterwards, and that answer does not depend on when the
  // abort landed relative to the write.
  assert.equal(server.listening, true, "the server stopped listening after an abort");
  const after = await fetchPath("/");
  assert.equal(after.status, 200);
  assert.ok(after.body.equals(readFileSync(join(ROOT, "index.html"))));
});
