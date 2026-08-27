/*
 * serve.test.js — the command-line front door, as a pair of functions and as a
 * real process.
 *
 * bin/serve.js was the only unit here with no peer test, and the reason was
 * structural rather than an oversight: importing it used to bind a port, so a
 * suite could not reach parseArgs or readPort without starting a server. It
 * now only listens when it is the command being run, and these cases exercise
 * both halves - the parsing directly, the process by spawning it.
 *
 * Every spawned child is signalled in a finally and its exit code asserted,
 * and every wait is bounded: a case that hangs waiting for a line that never
 * comes is a suite that reports nothing at all rather than a red line.
 */

import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { request } from "node:http";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { after, test } from "node:test";
import { fileURLToPath } from "node:url";

import { parseArgs, readPort } from "../bin/serve.js";

const HERE = dirname(fileURLToPath(import.meta.url));
const SITE = join(HERE, "..");
const CLI = join(SITE, "bin", "serve.js");
const PUBLIC = join(SITE, "public");
const STARTUP_MS = 10000;
const SHUTDOWN_MS = 10000;
// Not token-shaped, deliberately: this is planted content whose job is to be
// looked for in a response body.
const SENTINEL = "unusable-root-file-contents";

const running = new Set();

after(() => {
  for (const child of running) {
    child.kill("SIGKILL");
  }
});

// Start the CLI and hand back the URL it reports. The URL is read from stdout
// rather than assumed, because the whole point of port 0 is that the number is
// not knowable in advance.
function startCli(args) {
  const child = spawn(process.execPath, [CLI, ...args], { cwd: SITE });
  running.add(child);
  child.stdout.setEncoding("utf8");
  child.stderr.setEncoding("utf8");
  let noise = "";
  child.stderr.on("data", (chunk) => {
    noise += chunk;
  });
  const url = new Promise((settle, fail) => {
    let out = "";
    const timer = setTimeout(() => {
      fail(new Error("no URL within " + STARTUP_MS + "ms; stderr: " + noise));
    }, STARTUP_MS);
    child.stdout.on("data", (chunk) => {
      out += chunk;
      const hit = out.match(/listening on (http:\S+)/);
      if (hit) {
        clearTimeout(timer);
        settle(hit[1]);
      }
    });
    child.on("error", fail);
    child.on("exit", (code) => {
      clearTimeout(timer);
      fail(new Error("the CLI exited with code " + code + " before printing a URL; stderr: " + noise));
    });
  });
  return { child, url };
}

function stopCli(child, signal) {
  return new Promise((settle, fail) => {
    const timer = setTimeout(() => {
      child.kill("SIGKILL");
      fail(new Error("the CLI did not exit within " + SHUTDOWN_MS + "ms of " + signal));
    }, SHUTDOWN_MS);
    child.once("exit", (code, sig) => {
      clearTimeout(timer);
      running.delete(child);
      settle({ code, signal: sig });
    });
    child.kill(signal);
  });
}

function get(base, path) {
  const where = new URL(base);
  return new Promise((settle, fail) => {
    const call = request(
      { host: where.hostname, port: where.port, path, method: "GET" },
      (response) => {
        const chunks = [];
        response.on("data", (chunk) => chunks.push(chunk));
        response.on("end", () =>
          settle({ status: response.statusCode, body: Buffer.concat(chunks).toString("utf8") }),
        );
      },
    );
    call.on("error", fail);
    call.end();
  });
}

test("parse-args-defaults-to-port-0-and-the-bundled-public-root", () => {
  const options = parseArgs([]);
  // Port 0 is the default on purpose: the operating system picks a free port,
  // so a run can never collide with whatever else holds a fixed number.
  assert.equal(options.port, 0);
  assert.equal(options.root, resolve(PUBLIC));
  // The default has to be a root that actually holds the site, or the default
  // is a promise rather than a setting.
  assert.ok(readFileSync(join(options.root, "index.html"), "utf8").includes("<nav"));
});

test("parse-args-reads-port-and-root-and-ignores-unknown-flags", () => {
  assert.equal(parseArgs(["--port", "8080"]).port, 8080);
  assert.equal(parseArgs(["--root", join(tmpdir(), "somewhere")]).root, join(tmpdir(), "somewhere"));
  // A relative root becomes absolute, so the fence downstream always compares
  // two absolute paths.
  assert.equal(parseArgs(["--root", "public"]).root, resolve("public"));
  // Unknown flags are ignored rather than guessed at, and must not swallow the
  // flags around them.
  const mixed = parseArgs(["--verbose", "--port", "1234", "--nope", "--root", "public"]);
  assert.equal(mixed.port, 1234);
  assert.equal(mixed.root, resolve("public"));
  // Nothing given, nothing changed.
  assert.deepEqual(parseArgs(["--verbose"]), parseArgs([]));
});

test("read-port-rejects-values-that-are-not-whole-ports", () => {
  for (const [text, expected] of [["0", 0], ["1234", 1234], ["65535", 65535]]) {
    assert.equal(readPort(text), expected);
  }
  for (const bad of ["-1", "65536", "1.5", "abc", undefined, "NaN"]) {
    assert.throws(
      () => readPort(bad),
      /whole number from 0 to 65535/,
      String(bad) + " was accepted as a port",
    );
  }
  // Measured rather than assumed, and pinned here so a change to it is
  // visible: the check is Number() coercion plus a range, so it also accepts
  // spellings a reader might not expect - "0x10" is 16 and "1e3" is 1000. Both
  // are whole numbers in range, so this is breadth in what counts as spelling a
  // port, not a hole in the range check. Recorded as behaviour, not blessed as
  // a design: nothing in this round examined it.
  assert.equal(readPort("0x10"), 16);
  assert.equal(readPort("1e3"), 1000);
});

test("cli-prints-its-bound-loopback-url-and-exits-0-on-sigterm-and-sigint", async () => {
  for (const signal of ["SIGTERM", "SIGINT"]) {
    const { child, url } = startCli(["--port", "0"]);
    let exit;
    try {
      const base = await url;
      // Loopback, and a real port the OS chose rather than the 0 that was asked
      // for. A bench server reachable from another machine is different
      // software with the same name.
      assert.match(base, /^http:\/\/127\.0\.0\.1:\d+\/$/, "the CLI reported " + base);
      assert.notEqual(new URL(base).port, "0", "the CLI reported the port it asked for, not the one it got");
      const response = await get(base, "/");
      assert.equal(response.status, 200);
      assert.equal(response.body, readFileSync(join(PUBLIC, "index.html"), "utf8"));
    } finally {
      exit = await stopCli(child, signal);
    }
    // Exit 0 and not killed BY the signal: a process that needs killing twice
    // is one that will one day be left running.
    assert.equal(exit.code, 0, "the CLI exited " + exit.code + " on " + signal);
    assert.equal(exit.signal, null, "the CLI died from " + signal + " instead of handling it");
  }
});

test("cli-with-an-unusable-root-serves-nothing-and-leaks-nothing", async () => {
  const scratch = mkdtempSync(join(tmpdir(), "stress-site-root-"));
  try {
    const asFile = join(scratch, "not-a-directory.txt");
    writeFileSync(asFile, SENTINEL + "\n", "utf8");
    const missing = join(scratch, "no-such-directory");

    // --root is assigned unvalidated, unlike --port which is range-checked, and
    // it is the input that sets the confinement root itself. What that costs
    // was settled by running it rather than by reasoning about it: both shapes
    // answer 404 for everything and the process keeps serving.
    for (const root of [missing, asFile]) {
      const { child, url } = startCli(["--port", "0", "--root", root]);
      try {
        const base = await url;
        for (const path of ["/", "/index.html", "/not-a-directory.txt", "/../not-a-directory.txt"]) {
          const response = await get(base, path);
          assert.ok(
            response.status === 404 || response.status === 400,
            "root " + root + " GET " + path + " answered " + response.status,
          );
          assert.ok(
            !response.body.includes(SENTINEL),
            "an unusable root leaked file contents on GET " + path,
          );
        }
        // Still answering afterwards: an unusable root must not take the
        // process down, which is the difference between failing safe and
        // failing.
        assert.equal((await get(base, "/")).status, 404);
      } finally {
        const exit = await stopCli(child, "SIGTERM");
        assert.equal(exit.code, 0, "the CLI exited " + exit.code + " with root " + root);
      }
    }
  } finally {
    rmSync(scratch, { recursive: true, force: true });
  }
});
