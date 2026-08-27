/*
 * mime.js — the declared content types, and nothing implicit.
 *
 * Every extension this site serves is named here on purpose. Anything not on
 * the list is handed back as application/octet-stream rather than guessed at:
 * a wrong Content-Type is a security question, not a cosmetic one, so the
 * unknown case is deliberately the boring one.
 *
 * Paths are POSIX paths, which is what a URL path is after the fence in
 * safepath.js has resolved it.
 */

const TYPES = new Map([
  [".html", "text/html; charset=utf-8"],
  [".css", "text/css; charset=utf-8"],
  [".js", "text/javascript; charset=utf-8"],
  [".mjs", "text/javascript; charset=utf-8"],
  [".json", "application/json; charset=utf-8"],
  [".txt", "text/plain; charset=utf-8"],
  [".svg", "image/svg+xml"],
  [".ico", "image/vnd.microsoft.icon"],
]);

/** What an unknown extension is served as. Never a guess. */
export const DEFAULT_TYPE = "application/octet-stream";

/**
 * The lower-cased extension of a path, including its dot, or "" when there is
 * none. A bare ".xyz" is itself an extension, so callers may pass either a
 * whole file name or just the suffix.
 */
export function extensionOf(filePath) {
  const base = filePath.slice(filePath.lastIndexOf("/") + 1);
  const dot = base.lastIndexOf(".");
  if (dot === -1) {
    return "";
  }
  return base.slice(dot).toLowerCase();
}

/** The declared type for a path, or DEFAULT_TYPE when it is not on the list. */
export function contentTypeFor(filePath) {
  const ext = extensionOf(filePath);
  if (TYPES.has(ext)) {
    return TYPES.get(ext);
  }
  return DEFAULT_TYPE;
}

/** Every extension this module declares, sorted, for the coverage assertion. */
export function declaredExtensions() {
  return [...TYPES.keys()].sort();
}
