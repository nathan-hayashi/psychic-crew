#!/usr/bin/env node
/*
 * serve.js — the command-line front door.
 *
 * Default port is 0 on purpose: the operating system hands back a free port,
 * the process prints the one it actually got, and a run can never collide with
 * whatever else is holding a fixed number on this machine. That default is
 * also what lets the suite start real servers without a port registry.
 *
 * SIGTERM and SIGINT drop every connection and exit 0. A bench process that
 * needs to be killed twice is a bench process that will one day be left
 * running.
 */

import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { close, createSiteServer, listen } from "../src/server.js";

const HERE = dirname(fileURLToPath(import.meta.url));
const DEFAULT_ROOT = resolve(HERE, "..", "public");

function readPort(text) {
  const port = Number(text);
  if (!Number.isInteger(port) || port < 0 || port > 65535) {
    throw new Error("--port takes a whole number from 0 to 65535");
  }
  return port;
}

/** Parse argv. Unknown flags are ignored rather than guessed at. */
export function parseArgs(argv) {
  const options = { port: 0, root: DEFAULT_ROOT };
  for (let i = 0; i < argv.length; i += 1) {
    if (argv[i] === "--port") {
      options.port = readPort(argv[i + 1]);
      i += 1;
    }
    if (argv[i] === "--root") {
      options.root = resolve(argv[i + 1]);
      i += 1;
    }
  }
  return options;
}

function installShutdown(server) {
  const stop = function () {
    close(server).then(function () {
      process.exit(0);
    });
  };
  process.on("SIGTERM", stop);
  process.on("SIGINT", stop);
}

const options = parseArgs(process.argv.slice(2));
const server = createSiteServer(options.root);
const bound = await listen(server, options.port);
installShutdown(server);
console.log("stress-site listening on " + bound.url);
