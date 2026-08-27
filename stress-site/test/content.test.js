/*
 * content.test.js — the pages, checked as artifacts rather than as promises.
 *
 * Every assertion here binds to the bytes that would change if the property
 * stopped being true. "No external origin" is not a policy this file restates;
 * it is a scan of the two pages and the two assets they load.
 *
 * Each case also carries a floor on how much it examined. A loop that finds
 * nothing to check passes silently, and a check that can pass vacuously is not
 * a check.
 *
 * One case here does run something: the nav case executes the shipped app.js
 * against the shipped markup in a bare context with a hand-built stand-in for
 * the few DOM calls that file makes. It is written that way so the assertion
 * binds to the two artifacts as served rather than to a copy of the logic,
 * which is the failure mode that let a matcher which matched nothing ship.
 */

import assert from "node:assert/strict";
import { readdirSync, readFileSync, statSync } from "node:fs";
import { dirname, extname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { test } from "node:test";
import { runInNewContext } from "node:vm";

import { DEFAULT_TYPE, contentTypeFor, declaredExtensions } from "../src/mime.js";
import { resolveAsset } from "../src/safepath.js";

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = join(HERE, "..", "public");
const PAGES = ["index.html", "privacy.html"];
const ASSETS = ["styles.css", "app.js"];

function assetText(name) {
  return readFileSync(join(ROOT, name), "utf8");
}

function refsIn(text) {
  return [...text.matchAll(/(?:href|src)="([^"]*)"/g)].map((hit) => hit[1]);
}

function walk(dir) {
  const found = [];
  for (const entry of readdirSync(dir).sort()) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) {
      found.push(...walk(full));
    } else {
      found.push(full);
    }
  }
  return found;
}

function sectionOf(text, id) {
  const start = text.indexOf('id="' + id + '"');
  if (start === -1) {
    return "";
  }
  const end = text.indexOf("</section>", start);
  return text.slice(start, end);
}

test("every-asset-referenced-by-a-page-resolves-on-disk", () => {
  const checked = [];
  for (const page of PAGES) {
    for (const ref of refsIn(assetText(page))) {
      // Fragment-only navigation names a place on the page, not a file. Both
      // pages use it for their section nav, so treating "#visits" as an asset
      // would fail this case on correct markup.
      if (ref.startsWith("#")) {
        continue;
      }
      assert.notEqual(
        resolveAsset("/" + ref, ROOT),
        null,
        page + ' references "' + ref + '" and no such file is on disk',
      );
      checked.push(page + " -> " + ref);
    }
  }
  assert.ok(
    checked.length >= 6,
    "expected at least 6 file references to check, saw " + checked.length,
  );
});

test("no-page-references-an-external-origin", () => {
  const refs = [];
  for (const name of [...PAGES, ...ASSETS]) {
    const text = assetText(name);
    assert.ok(!text.includes("://"), name + " carries a scheme-bearing URL");
    assert.ok(!text.includes("@import"), name + " pulls in another file by at-rule");
    for (const ref of refsIn(text)) {
      refs.push(ref);
      assert.ok(!ref.includes(":"), name + ' references "' + ref + '" by scheme');
      assert.ok(!ref.startsWith("//"), name + ' references "' + ref + '" protocol-relative');
    }
  }
  assert.ok(refs.length >= 12, "expected at least 12 references to scan, saw " + refs.length);
});

test("declared-content-types-cover-every-served-extension", () => {
  const declared = declaredExtensions();
  const served = new Set(walk(ROOT).map((file) => extname(file).toLowerCase()));
  for (const ext of served) {
    assert.ok(declared.includes(ext), "public/ serves " + ext + " with no declared type");
    assert.notEqual(
      contentTypeFor("served" + ext),
      DEFAULT_TYPE,
      ext + " would be served as the unknown-type fallback",
    );
  }
  assert.ok(served.size >= 3, "expected at least 3 served extensions, saw " + served.size);
});

test("privacy-page-states-collection-retention-and-contact", () => {
  const text = assetText("privacy.html");
  for (const topic of ["collection", "retention", "contact"]) {
    const section = sectionOf(text, topic);
    assert.notEqual(section, "", "the privacy page has no " + topic + " section");
    assert.match(
      section,
      new RegExp("<h2[^>]*>\\s*" + topic + "\\b", "i"),
      "the " + topic + " section has no heading that names it",
    );
    // A named anchor over nothing is not a statement. Bind to substance.
    assert.ok(
      section.length >= 400,
      "the " + topic + " section is " + section.length + " characters and states too little",
    );
  }
});

test("both-pages-share-one-stylesheet-and-no-inline-script", () => {
  const sheets = new Set();
  for (const page of PAGES) {
    const text = assetText(page);
    const links = [...text.matchAll(/<link[^>]*rel="stylesheet"[^>]*>/g)];
    assert.equal(links.length, 1, page + " links " + links.length + " stylesheets, expected 1");
    sheets.add(links[0][0].match(/href="([^"]*)"/)[1]);

    const scripts = [...text.matchAll(/<script([^>]*)>([\s\S]*?)<\/script>/g)];
    assert.ok(scripts.length >= 1, page + " loads no script at all");
    for (const [, attributes, body] of scripts) {
      assert.match(attributes, /\ssrc="/, page + " has a script element with no src");
      assert.equal(body.trim(), "", page + " has an inline script body");
    }
    assert.doesNotMatch(text, / on[a-z]+="/, page + " carries an inline event handler");
  }
  assert.equal(sheets.size, 1, "the pages link different stylesheets: " + [...sheets].join(", "));
});

// The hrefs of a page's nav, in document order, read out of the real markup.
function navHrefs(pageText) {
  const opened = pageText.indexOf("<nav");
  const closed = pageText.indexOf("</nav>", opened);
  assert.ok(opened !== -1 && closed !== -1, "the page has no <nav> to read");
  return refsIn(pageText.slice(opened, closed));
}

// Run the shipped app.js against a stand-in for the handful of DOM calls it
// makes, and hand back the links so the case can inspect what it marked.
// querySelector returns null so the filter half short-circuits: this case is
// about the nav and should not depend on the cards.
function markNav(pathname, hrefs) {
  const links = hrefs.map((href) => {
    const attributes = { href };
    return {
      getAttribute: (name) => (name in attributes ? attributes[name] : null),
      setAttribute: (name, value) => {
        attributes[name] = value;
      },
      attributes,
    };
  });
  const document = {
    location: { pathname },
    querySelectorAll: (selector) => (selector === "nav a[href]" ? links : []),
    querySelector: () => null,
  };
  runInNewContext(assetText("app.js"), { document });
  return links;
}

function currentHrefs(links) {
  return links
    .filter((link) => link.attributes["aria-current"] === "page")
    .map((link) => link.attributes.href);
}

test("nav-marks-the-current-page-on-both-pages", () => {
  // styles.css styles nav a[aria-current="page"]. If no page can ever set it,
  // that rule is dead and the reader is never told where they are.
  assert.ok(
    assetText("styles.css").includes('aria-current="page"'),
    "the stylesheet no longer styles the current nav link, so this case guards nothing",
  );

  let examined = 0;
  for (const page of PAGES) {
    const hrefs = navHrefs(assetText(page));
    assert.ok(hrefs.length >= 4, page + " nav offers only " + hrefs.length + " links");

    // Every URL shape a reader can arrive by must reach the same answer.
    const arrivals = page === "index.html" ? ["/", "/index.html"] : ["/" + page];
    for (const pathname of arrivals) {
      const marked = currentHrefs(markNav(pathname, hrefs));
      assert.deepEqual(
        marked,
        [page],
        page + " visited as " + pathname + " marked " + JSON.stringify(marked) + ", expected exactly [" + page + "]",
      );
      examined += 1;
    }

    // The other page's entry must NOT be marked, or "current" means nothing.
    assert.ok(
      hrefs.includes(page),
      page + " nav never names itself, so no link on it can ever be current",
    );
  }
  assert.equal(examined, 3, "expected 3 page/URL combinations, examined " + examined);
});

test("unknown-and-missing-extensions-are-served-as-the-declared-default", () => {
  // mime.js's header calls the unknown case a security question rather than a
  // cosmetic one. The suite asserted only the negative half - that declared
  // extensions are NOT the fallback - so the fallback itself was never checked
  // to actually be the fallback.
  assert.equal(DEFAULT_TYPE, "application/octet-stream");
  for (const path of [
    "file.unknownext",
    "notes.xyz",
    "README",
    "/deep/path/with-no-dot",
    "archive.tar.gz",
    ".hiddenrc",
  ]) {
    assert.equal(
      contentTypeFor(path),
      DEFAULT_TYPE,
      path + " was typed as " + contentTypeFor(path) + " instead of the fallback",
    );
  }
  // The other side of the same line: a declared extension must not reach the
  // fallback, including when it is spelled in capitals.
  for (const path of ["page.html", "page.HTML", "sheet.CSS", "code.mjs"]) {
    assert.notEqual(
      contentTypeFor(path),
      DEFAULT_TYPE,
      path + " fell through to the fallback despite being declared",
    );
  }
});
