# stress-site — Kettle Lane Cats & Dogs

A two-page static site — a landing page and a privacy page — served from loopback by a small
server built out of the Node standard library. It exists as the workload for the STRESS-1
hot-bench run: the full crew builds it under the arbiter, and the run is measured, not the site.

Node standard library only. **Zero dependencies**, nothing to install, no build step, and no
byte fetched from anywhere. Both pages render with the network unplugged, and that is a property
you can confirm from the page source rather than a promise made in prose.

## What is here after Stage A

```text
package.json          module, engines >= 22, no dependency keys at all
README.md             this file
public/index.html     the landing page: five sections, original copy
public/privacy.html   collection, retention, contact
public/styles.css     the whole stylesheet; no at-rule pulls in another file
public/app.js         DOM-only enhancement; no network client is constructed
```

The server, the router, the path fence, the CLI, the branch-count proxy and the test suite arrive
in Stage B under `src/`, `bin/`, `tools/` and `test/`. Until then `npm start` has no entry point to
run — `package.json` names it because the file layout is fixed by the approved plan, not because
the file exists yet.

## Running it (Stage B)

```sh
npm start
```

The server binds the loopback interface only and never the all-interfaces address. It reports the
port it actually bound, so `--port 0` is the default and a run never collides with a port someone
else is holding. Open the reported address — `http://127.0.0.1:<port>` — to read the site.

## Testing it (Stage B)

```sh
npm test
```

which is exactly:

```sh
node --test --test-reporter=tap 'test/**/*.test.js'
```

The glob is quoted so node expands it, not the shell; unquoted, or handed a bare directory, the
runner collects zero cases and still exits nonzero for an unrelated reason. The TAP reporter is
required to read a machine-checkable `# pass` line — the default reporter prints a decorated form
that is not the same string.

## The branch-count proxy

`tools/branch-proxy.mjs` (Stage B) reports one number per function and the suite fails the run if
any function exceeds it.

**The threshold is 8 branches per function. A function counted at 9 or more fails.**

The count is one plus each `if`, `else if`, loop, `case`, `&&`, `||`, and ternary in the function
body. That is a **proxy**, deliberately named as one: it is not cyclomatic complexity, it does not
build a control-flow graph, and it is barred from the frozen comparison rubric for exactly that
reason. It is here to catch a function that has quietly grown too many decisions, which is a
question a cheap syntactic count answers honestly.

Every function in `public/app.js` is written to sit well under the threshold today.

## Constraints this site is built under

- **Nothing installed, nothing brought in.** No package manager reaches the network at any point.
- **Loopback only.** No external origin, no embedded map, no fetched typeface, no measurement
  script, no third-party host of any kind on either page. Every `href` and `src` is relative.
- **Original content only.** The Kettle Lane copy was written for this site. Nothing is adapted
  from a template or lifted from another page; the business is fictional and so is its street.
- **The runtime writes nothing inside this directory.** Scratch files, including the planted
  negative-control fixture the complexity suite needs, go to the operating system's temporary
  directory and never into the repository.
- **No machine-specific absolute paths, no token-shaped literals, no diagram fences** in any file
  here — each of those is checked, not assumed.
