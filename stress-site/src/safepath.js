/*
 * safepath.js — the traversal fence.
 *
 * Two exports with two different jobs, kept apart on purpose so the router can
 * tell "I refuse to consider this" (400) from "I considered it and there is no
 * such file" (404):
 *
 *   refuses(urlPath)              a decision about the request text alone
 *   resolveAsset(urlPath, root)   an absolute path to a real file, or null
 *
 * The fence reads the RAW request target. It must never be handed a value that
 * has been through the URL parser first: `new URL("/../x", base)` quietly
 * normalises the dot-dot away, so a fence placed after it would be inspecting
 * a string the attacker never sent. Decoding happens here, exactly once, and
 * a doubly-encoded segment therefore stays a literal file name that does not
 * exist rather than becoming a second chance at traversal.
 */

import { statSync } from "node:fs";
import { resolve, sep } from "node:path";

/** What "/" serves. */
export const INDEX_FILE = "index.html";

/** Percent-decode a request target, or null when it is malformed. */
export function decodeUrlPath(target) {
  try {
    return decodeURIComponent(target);
  } catch {
    return null;
  }
}

/**
 * True when the request text is refused outright: not absolute, malformed
 * encoding, a NUL, a backslash, or any ".." segment once decoded.
 */
export function refuses(urlPath) {
  if (typeof urlPath !== "string") {
    return true;
  }
  if (!urlPath.startsWith("/")) {
    return true;
  }
  const decoded = decodeUrlPath(urlPath);
  if (decoded === null) {
    return true;
  }
  if (decoded.includes("\0")) {
    return true;
  }
  if (decoded.includes("\\")) {
    return true;
  }
  return decoded.split("/").includes("..");
}

function isInside(target, root) {
  return target === root || target.startsWith(root + sep);
}

/**
 * The absolute path of the real file a request target names inside root, or
 * null. Null covers all three of: refused text, escapes the root, and there is
 * no regular file there. A caller that needs to tell those apart asks
 * refuses() first.
 */
export function resolveAsset(urlPath, rootDir) {
  if (refuses(urlPath)) {
    return null;
  }
  const decoded = decodeUrlPath(urlPath);
  const relative = decoded === "/" ? INDEX_FILE : decoded.slice(1);
  const root = resolve(rootDir);
  const target = resolve(root, relative);
  if (!isInside(target, root)) {
    return null;
  }
  const found = statSync(target, { throwIfNoEntry: false });
  if (found === undefined) {
    return null;
  }
  if (!found.isFile()) {
    return null;
  }
  return target;
}
