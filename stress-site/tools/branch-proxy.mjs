#!/usr/bin/env node
/*
 * branch-proxy.mjs — one number per function, and an honest name for it.
 *
 * The number is 1 plus each `if`, `else if`, `for`, `while`, `do`, `case`,
 * `&&`, `||` and ternary `?` found in a function body. That is a PROXY. It is
 * not cyclomatic complexity: it builds no control-flow graph, it cannot see
 * that two branches are mutually exclusive, and it would be wrong to report
 * its output as CC. It is barred from the frozen comparison rubric for exactly
 * that reason. What it is good for is noticing that a function has quietly
 * accumulated more decisions than a reader can hold at once.
 *
 * Usage:  node tools/branch-proxy.mjs [path ...]     (default: src bin)
 * Output: one NAME<TAB>COUNT line per function on stdout; offenders and a
 *         summary on stderr; exit 0 when every count is at or under 8.
 *
 * How it reads code, stated plainly so the gaps are known rather than
 * discovered:
 *   - Comments and string/template literal contents are blanked before
 *     counting, so a `?` in prose or a `||` in a message costs nothing. Line
 *     numbers are preserved by blanking rather than deleting.
 *   - REGEX LITERALS ARE NOT UNDERSTOOD. A regex containing a quote or a
 *     `//` would confuse the scanner. No file under src/ or bin/ contains one,
 *     and this tool contains none either. This gap gets a fix when evidence
 *     produces an instance, not before.
 *   - Nested functions count toward the enclosing function as well as being
 *     reported in their own right, so the rows are a report, not a partition.
 *     A function that hides its decisions in an inner callback does not get to
 *     look simple.
 *   - Anything not inside a declared function - top-level code, and any
 *     branch in an arrow assigned at module scope - is reported as
 *     `<module>` and held to the same threshold. Nothing escapes counting by
 *     not being a `function`.
 */

import { readFileSync, readdirSync, statSync } from "node:fs";
import { extname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

/** A function counted at 9 or more fails the run. */
export const THRESHOLD = 8;

const DEFAULT_TARGETS = ["src", "bin"];
const EXTENSIONS = [".js", ".mjs"];
const KEYWORD = "function";
const ANONYMOUS = "(anonymous)";
const MODULE_SCOPE = "<module>";
const IDENT_CHARS =
  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_$";
const BRANCH_WORDS = ["if", "for", "while", "do", "case"];
const QUOTES = ["'", '"', "`"];

function blank(chunk) {
  return chunk
    .split("\n")
    .map(function (line) {
      return " ".repeat(line.length);
    })
    .join("\n");
}

function isEscaped(text, at) {
  let slashes = 0;
  let cursor = at - 1;
  while (cursor >= 0 && text[cursor] === "\\") {
    slashes += 1;
    cursor -= 1;
  }
  return slashes % 2 === 1;
}

function scanString(text, start) {
  const quote = text[start];
  let i = start + 1;
  while (i < text.length) {
    if (text[i] === quote && !isEscaped(text, i)) {
      return i + 1;
    }
    i += 1;
  }
  return text.length;
}

function scanTo(text, start, closer, width) {
  const end = text.indexOf(closer, start + 2);
  if (end === -1) {
    return text.length;
  }
  return end + width;
}

/** Blank out comments and literal contents, preserving offsets and lines. */
function stripNoise(text) {
  let out = "";
  let i = 0;
  while (i < text.length) {
    const pair = text.slice(i, i + 2);
    let end = i + 1;
    if (pair === "/*") {
      end = scanTo(text, i, "*/", 2);
    } else if (pair === "//") {
      end = scanTo(text, i, "\n", 0);
    } else if (QUOTES.includes(text[i])) {
      end = scanString(text, i);
    }
    out += end === i + 1 ? text[i] : blank(text.slice(i, end));
    i = end;
  }
  return out;
}

function readWord(text, start) {
  let end = start;
  while (end < text.length && IDENT_CHARS.includes(text[end])) {
    end += 1;
  }
  return text.slice(start, end);
}

function skipSpace(text, start) {
  let i = start;
  while (i < text.length && text[i] === " ") {
    i += 1;
  }
  return i;
}

function pairScore(pair) {
  if (pair === "&&") {
    return 1;
  }
  if (pair === "||") {
    return 1;
  }
  return 0;
}

// `??` and `?.` are not decisions this proxy counts, and neither half of them
// may be mistaken for a ternary.
function questionScore(code, at) {
  if (code[at] !== "?") {
    return 0;
  }
  if (code[at + 1] === "?") {
    return 0;
  }
  if (code[at - 1] === "?") {
    return 0;
  }
  if (code[at + 1] === ".") {
    return 0;
  }
  return 1;
}

function countBranches(code) {
  let count = 1;
  let i = 0;
  while (i < code.length) {
    const word = readWord(code, i);
    if (word.length > 0) {
      count += BRANCH_WORDS.includes(word) ? 1 : 0;
      i += word.length;
      continue;
    }
    count += pairScore(code.slice(i, i + 2));
    count += questionScore(code, i);
    i += 1;
  }
  return count;
}

function matchPair(code, open, opener, closer) {
  let depth = 0;
  let i = open;
  while (i < code.length) {
    if (code[i] === opener) {
      depth += 1;
    } else if (code[i] === closer) {
      depth -= 1;
      if (depth === 0) {
        return i + 1;
      }
    }
    i += 1;
  }
  return code.length;
}

function rangeAt(code, at) {
  const before = at === 0 ? " " : code[at - 1];
  if (IDENT_CHARS.includes(before)) {
    return null;
  }
  const nameStart = skipSpace(code, at + KEYWORD.length);
  const name = readWord(code, nameStart);
  const paren = code.indexOf("(", nameStart);
  if (paren === -1) {
    return null;
  }
  const brace = code.indexOf("{", matchPair(code, paren, "(", ")"));
  if (brace === -1) {
    return null;
  }
  return {
    name: name.length > 0 ? name : ANONYMOUS,
    start: brace,
    end: matchPair(code, brace, "{", "}"),
  };
}

function functionRanges(code) {
  const ranges = [];
  let i = 0;
  while (i < code.length) {
    const at = code.indexOf(KEYWORD, i);
    if (at === -1) {
      return ranges;
    }
    const range = rangeAt(code, at);
    if (range !== null) {
      ranges.push(range);
    }
    i = at + KEYWORD.length;
  }
  return ranges;
}

function outermost(ranges) {
  return ranges.filter(function (range) {
    return !ranges.some(function (other) {
      return other.start < range.start && range.end <= other.end;
    });
  });
}

function maskOutermost(code, ranges) {
  let masked = code;
  for (const range of outermost(ranges)) {
    masked =
      masked.slice(0, range.start) +
      blank(masked.slice(range.start, range.end)) +
      masked.slice(range.end);
  }
  return masked;
}

/** Every counted unit in one source text, module scope included. */
export function analyse(text) {
  const code = stripNoise(text);
  const ranges = functionRanges(code);
  const rows = ranges.map(function (range) {
    return { name: range.name, count: countBranches(code.slice(range.start, range.end)) };
  });
  rows.push({ name: MODULE_SCOPE, count: countBranches(maskOutermost(code, ranges)) });
  return rows;
}

function collectFiles(target, found) {
  const info = statSync(target);
  if (info.isFile()) {
    if (EXTENSIONS.includes(extname(target))) {
      found.push(target);
    }
    return found;
  }
  for (const entry of readdirSync(target).sort()) {
    collectFiles(join(target, entry), found);
  }
  return found;
}

function displayName(file) {
  const rel = relative(process.cwd(), file);
  if (rel.startsWith("..")) {
    return file;
  }
  return rel;
}

function rowsFor(targets) {
  const files = [];
  for (const target of targets) {
    collectFiles(resolve(target), files);
  }
  const rows = [];
  for (const file of files) {
    for (const entry of analyse(readFileSync(file, "utf8"))) {
      rows.push({ name: displayName(file) + "::" + entry.name, count: entry.count });
    }
  }
  return rows;
}

function report(rows) {
  for (const row of rows) {
    process.stdout.write(row.name + "\t" + row.count + "\n");
  }
  const offenders = rows.filter(function (row) {
    return row.count > THRESHOLD;
  });
  for (const row of offenders) {
    process.stderr.write(
      "OVER THRESHOLD\t" + row.name + "\tcounted " + row.count + " > " + THRESHOLD + "\n",
    );
  }
  const verdict = offenders.length === 0 ? "OK" : "FAIL";
  process.stderr.write(
    verdict + ": " + rows.length + " units checked, threshold " + THRESHOLD + ", " +
      offenders.length + " over\n",
  );
  return offenders.length === 0 ? 0 : 1;
}

export function main(argv) {
  const targets = argv.length > 0 ? argv : DEFAULT_TARGETS;
  return report(rowsFor(targets));
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  process.exit(main(process.argv.slice(2)));
}
