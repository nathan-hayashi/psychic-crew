/*
 * complexity.test.js — the proxy, and a proof that it can fail.
 *
 * A threshold tool that has never been seen to go red is indistinguishable
 * from a tool that always returns zero, and a green suite looks the same
 * either way. So these two cases are a pair: the first says the real source
 * is under the threshold, the second plants a function that must break it and
 * insists the tool notices by name.
 *
 * The planted fixture is written to the operating system's temporary
 * directory. Nothing in this file writes inside the repository - a suite that
 * dirties the tree it is asserting about would falsify the tracked-file count
 * the phase is measured on.
 *
 * The number this reports is a PROXY, not cyclomatic complexity. That naming
 * is enforced in the tool's own header and is why it is barred from the frozen
 * comparison rubric.
 */

import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
const SITE = join(HERE, "..");
const PROXY = join(SITE, "tools", "branch-proxy.mjs");
const THRESHOLD = 8;

function runProxy(targets, cwd) {
  const result = spawnSync(process.execPath, [PROXY, ...targets], {
    cwd,
    encoding: "utf8",
  });
  const rows = result.stdout
    .split("\n")
    .filter((line) => line.includes("\t"))
    .map((line) => {
      const [name, count] = line.split("\t");
      return { name, count: Number(count) };
    });
  return { status: result.status, rows, output: result.stdout + result.stderr };
}

const NINE_BRANCH_SOURCE = `function plantedNineBranches(a, b, c) {
  if (a) {
    return 1;
  } else if (b) {
    return 2;
  }
  for (const item of c) {
    while (item) {
      break;
    }
  }
  switch (a) {
    case 1:
      return 3;
    case 2:
      return 4;
  }
  return (a && b) || c;
}

function twoBranchControl(a) {
  if (a) {
    return 1;
  }
  return 0;
}
`;

test("complexity-branch-count-proxy-max-8-per-function", () => {
  const run = runProxy(["src", "bin"], SITE);
  assert.equal(run.status, 0, "the proxy exited nonzero:\n" + run.output);
  for (const row of run.rows) {
    assert.ok(
      row.count <= THRESHOLD,
      row.name + " counted " + row.count + ", over the threshold of " + THRESHOLD,
    );
  }
  // Floors, so that a run which measured nothing cannot pass as a run which
  // measured everything and found it clean.
  assert.ok(run.rows.length >= 20, "the proxy reported only " + run.rows.length + " units");
  const names = run.rows.map((row) => row.name);
  for (const expected of [
    "src/router.js::route",
    "src/safepath.js::resolveAsset",
    "src/server.js::createSiteServer",
    "bin/serve.js::parseArgs",
  ]) {
    assert.ok(names.includes(expected), "the proxy never looked at " + expected);
  }
});

test("branch-proxy-flags-a-planted-nine-branch-function", () => {
  const scratch = mkdtempSync(join(tmpdir(), "stress-site-proxy-"));
  try {
    const planted = join(scratch, "planted.js");
    writeFileSync(planted, NINE_BRANCH_SOURCE, "utf8");
    const run = runProxy([planted], scratch);

    assert.notEqual(run.status, 0, "a nine-branch function did not fail the proxy");
    assert.ok(
      run.output.includes("plantedNineBranches"),
      "the failure never named the offender:\n" + run.output,
    );

    const offender = run.rows.find((row) => row.name.endsWith("::plantedNineBranches"));
    assert.notEqual(offender, undefined, "the offender was not reported at all");
    assert.equal(offender.count, 9, "the planted function was counted at " + offender.count);

    // Control on the control: the benign function in the very same file is
    // reported and passes, so the nonzero exit came from the planted branches
    // and not from anything about running the tool on a temporary file.
    const benign = run.rows.find((row) => row.name.endsWith("::twoBranchControl"));
    assert.notEqual(benign, undefined, "the benign function was not reported");
    assert.ok(benign.count <= THRESHOLD, "the benign control counted " + benign.count);
  } finally {
    rmSync(scratch, { recursive: true, force: true });
  }
});
