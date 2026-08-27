/*
 * server.js — the transport, and only the transport.
 *
 * Every decision this file makes has already been made by router.js. What is
 * left here is reading bytes, writing headers, and surviving a client that
 * leaves in the middle of a sentence.
 *
 * The host is a constant, and it is the loopback address. There is no flag to
 * widen it and no branch that could choose the all-interfaces address, because
 * a bench server that can be reached from another machine is a different piece
 * of software with the same name.
 */

import { readFile } from "node:fs/promises";
import { createServer } from "node:http";

import { route } from "./router.js";

/** The only address this server will ever bind. */
export const LOOPBACK_HOST = "127.0.0.1";

const TEXT_TYPE = "text/plain; charset=utf-8";

function ignore() {}

function send(res, decision, payload, headOnly) {
  const headers = {
    ...decision.headers,
    "content-length": String(payload.length),
  };
  res.writeHead(decision.status, headers);
  if (headOnly) {
    res.end();
    return;
  }
  res.end(payload);
}

async function payloadFor(decision) {
  if (decision.filePath === null) {
    return Buffer.from(decision.body, "utf8");
  }
  return readFile(decision.filePath);
}

// A request that dies mid-flight must cost this process nothing. Everything
// below is written so the only outcome of a vanished socket is a dropped
// response - never an unhandled rejection, never a listener left behind.
function failSafely(res) {
  try {
    if (res.headersSent) {
      res.end();
      return;
    }
    res.writeHead(500, { "content-type": TEXT_TYPE });
    res.end("Internal error.\n");
  } catch {
    res.destroy();
  }
}

async function handle(req, res, rootDir) {
  const decision = route(req.method, req.url, rootDir);
  const payload = await payloadFor(decision);
  send(res, decision, payload, req.method === "HEAD");
}

/** An http.Server for the site rooted at rootDir. Not yet listening. */
export function createSiteServer(rootDir) {
  const server = createServer(function (req, res) {
    req.on("error", ignore);
    res.on("error", ignore);
    handle(req, res, rootDir).catch(function () {
      failSafely(res);
    });
  });
  server.on("clientError", function (err, socket) {
    socket.destroy();
  });
  return server;
}

/** Listen, and report the port that was actually bound - never the one asked for. */
export function listen(server, port) {
  return new Promise(function (settle, fail) {
    server.once("error", fail);
    server.listen(port, LOOPBACK_HOST, function () {
      const bound = server.address();
      settle({
        host: bound.address,
        port: bound.port,
        url: "http://" + bound.address + ":" + bound.port + "/",
      });
    });
  });
}

/** Stop listening and drop every connection, idle or not. */
export function close(server) {
  return new Promise(function (settle) {
    server.closeAllConnections();
    server.close(function () {
      settle();
    });
  });
}
