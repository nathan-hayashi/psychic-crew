/*
 * router.js — the whole decision, made without a socket in the room.
 *
 * route() takes three strings and returns a plain object describing what the
 * response should be. It constructs no transport of any kind, holds no module
 * state, and never touches a request or response object, so the router suite
 * can exercise every status this server can produce without binding a port.
 * The live-server suite then proves the wiring separately, which keeps a
 * routing bug and a transport bug from hiding behind each other.
 *
 * Order matters and is load-bearing:
 *   1. method   - a disallowed verb is answered before the path is examined,
 *                 so POST /../secret is a 405, not a 400 that leaks the fact
 *                 that we looked.
 *   2. refusal  - the raw target, un-normalised, straight from the request.
 *   3. lookup   - null here means "no such file", never "not allowed".
 */

import { contentTypeFor } from "./mime.js";
import { refuses, resolveAsset } from "./safepath.js";

/** The only verbs a static file server needs. */
export const ALLOWED_METHODS = ["GET", "HEAD"];

const ALLOW_HEADER = ALLOWED_METHODS.join(", ");
const TEXT_TYPE = "text/plain; charset=utf-8";

/**
 * The path part of a request target, with any query string or fragment cut
 * off. Done by hand rather than with the URL parser: the parser normalises
 * dot-dot segments, and the fence downstream has to see the target as sent.
 */
export function splitTarget(target) {
  const cuts = [target.indexOf("?"), target.indexOf("#")].filter(function (at) {
    return at !== -1;
  });
  if (cuts.length === 0) {
    return target;
  }
  return target.slice(0, Math.min(...cuts));
}

function errorDecision(status, text, extraHeaders = {}) {
  return {
    status,
    headers: { "content-type": TEXT_TYPE, ...extraHeaders },
    filePath: null,
    body: text + "\n",
  };
}

/**
 * Decide the response for one request. Error bodies deliberately quote none of
 * the request back at the reader: reflecting an attacker-supplied path into a
 * body is a surface that costs nothing to simply not have, and a 404 is no
 * more useful for knowing how it was spelled.
 */
export function route(method, target, rootDir) {
  if (!ALLOWED_METHODS.includes(method)) {
    return errorDecision(405, "Method not allowed.", { allow: ALLOW_HEADER });
  }
  const pathname = splitTarget(target);
  if (refuses(pathname)) {
    return errorDecision(400, "Refused: that is not a path this server will look up.");
  }
  const filePath = resolveAsset(pathname, rootDir);
  if (filePath === null) {
    return errorDecision(404, "Not found: this server has no page at that address.");
  }
  return {
    status: 200,
    headers: { "content-type": contentTypeFor(filePath) },
    filePath,
    body: null,
  };
}
