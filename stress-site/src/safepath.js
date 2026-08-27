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
 *
 * CONTAINMENT MODEL, stated so the gaps are known rather than discovered:
 *   - Textual containment is not enough. resolve() + a string prefix test
 *     answers "does this path SPELL its way inside root", and a symlink makes
 *     that a different question from "does this path LAND inside root".
 *     Containment is therefore settled on realpathSync(), with every link in
 *     the path resolved, against the real path of the root.
 *   - Links are not banned, only escapes are: a link that lands inside root is
 *     served, because the property being defended is where bytes come from and
 *     not how the entry was spelled on disk.
 *   - Checking only the LAST component is not enough either, and this was
 *     measured rather than assumed: a symlinked DIRECTORY mid-path serves
 *     outside bytes while lstat() on the final component reports a plain file.
 *   - What remains is a time-of-check/time-of-use window. The path is verified
 *     here and opened later by the caller, so a link swapped in between is not
 *     covered. Saying so is the point: this fence bounds spelling and landing,
 *     not the interval.
 */

import { realpathSync, statSync } from "node:fs";
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

/**
 * Whether target lies at or under root, as text.
 *
 * NOT REDUNDANT WITH refuses(), which is the mistake this comment exists to
 * prevent. A target beginning with two slashes, such as "//etc/passwd", passes
 * refuses() completely: it starts with "/", decodes to itself, and carries no
 * NUL, no backslash and no ".." segment. resolve(root, relative) then DISCARDS
 * root entirely, because the relative part is itself absolute - it hands back
 * "/etc/passwd" - and this comparison is what rejects the result.
 *
 * VERIFIED BY EXECUTION rather than by reading, which is the only reason this
 * paragraph is allowed to assert it: refuses("//etc/passwd") === false,
 * resolve(root, "/etc/passwd") === "/etc/passwd", and the request answers 404
 * (this check) and not 400 (refuses). The status code is the observable
 * difference and the transport suite asserts it.
 *
 * Called TWICE by resolveAsset, on purpose, and neither call is spare:
 *   - on the resolved text, before the filesystem is consulted at all. That
 *     ordering is the point: a path that has already failed containment is
 *     never stat()ed, so a hostile absolute target cannot turn a refusal into
 *     an error. Measured, not assumed - a target naming a symlink loop makes
 *     statSync throw ELOOP, which throwIfNoEntry does not suppress, so a fence
 *     that looked first would answer 500 where this one answers 404. That is
 *     the case pinning this call site.
 *   - on the real path, after resolution, which is what makes containment
 *     survive symlinks (see the header).
 * Deleting either call turns a different test red. Deleting the function
 * breaks both.
 */
function isInside(target, root) {
  return target === root || target.startsWith(root + sep);
}

/**
 * The absolute path of the real file a request target names inside root, or
 * null. Null covers all four of: refused text, a path that spells its way out
 * of the root, a path that LANDS outside it through a symlink, and there being
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
  // Where the path LANDS, now that we know something is there. realpathSync is
  // safe to call only here: it throws on a missing entry, whereas the check
  // above is what lets an unusable root answer 404 instead of dying. The root
  // is resolved the same way because the root itself can be reached through a
  // link, and comparing a resolved path against an unresolved one would refuse
  // every request on such a machine.
  if (!isInside(realpathSync(target), realpathSync(root))) {
    return null;
  }
  return target;
}
