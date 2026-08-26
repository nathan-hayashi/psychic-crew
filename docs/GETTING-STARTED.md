# Getting started — the plain-language guide

This page is for a reader who wants the system working without learning its internals first.
The README beside it is the technical reference; everything here is also true there, in more words.

## What this is

A crew of eight AI specialists that runs inside [Claude Code](https://claude.com/claude-code),
built for IT-automation work. It reviews, fixes, tests, and records everything it does in ledger
files — and it is physically unable to finish a piece of work without your written approval. You
are the gate; the machine stops and waits for you by design.

It has a sibling, [psychic-crew-lite](https://github.com/nathan-hayashi/psychic-crew-lite) — a
smaller four-specialist crew. Install both, side by side, in the same folder.

## What you need

- A Mac, Linux machine, or Windows with WSL2 (Ubuntu). Everything runs in a terminal.
- `git`, `node` version 22 or newer, `npm`, and `jq` installed.
- [Claude Code](https://claude.com/claude-code) installed and signed in (`claude auth status`).
- No accounts, keys, or passwords beyond that. These repos hold no secrets and ask for none.

## Set it up once

Pick a folder to keep projects in (any folder works — `~/projects` is the default the tools
expect; if you use another, one extra line below). Then:

```bash
cd ~/projects
git clone https://github.com/nathan-hayashi/psychic-crew.git
git clone https://github.com/nathan-hayashi/psychic-crew-lite.git

cd ~/projects/psychic-crew && ./scripts/setup.sh
cd ~/projects/psychic-crew-lite && ./scripts/apply-models.sh && ./scripts/verify.sh
```

Success looks like two words: **READY** at the end of the first check, **no signal** at the end of
the second. If you keep the repos somewhere other than `~/projects`, tell the twin where its
parent lives (add to your shell profile):

```bash
export PSYCHIC_CREW_PARENT="$HOME/your-folder/psychic-crew"
```

Fresh-install note: a brand-new clone shows a few lines marked SKIP and a couple of lines saying
"describes the primary checkout" — both are normal. They mean "this machine has no work history
yet", not "something is broken".

## Daily use — the whole loop

1. Open a terminal **in the repo folder** and type `claude`. The folder you stand in decides
   which crew you get — that is the only rule.
2. The session greets you with where the project stands (it reads its own ledgers first).
3. Say what you want in plain words. The crew works, tests itself, and writes everything down.
4. It **stops** and shows you a summary with a token like `APPROVE SOMETHING`.
5. If you agree, type that token exactly as shown. Only then does anything become permanent.
   Typos are refused politely — the guard tells you which token is actually waiting.

Corrections: reply with numbers ("1: change X, 2: change Y") and only what you name changes.

## Which crew am I talking to?

- `pwd` before you type `claude` — the folder name is the answer.
- Ask it "how many agents do you have?" — this one says **8**, the twin says **4**.
- The greeting quotes this repo's own ledger; the twin's greeting quotes its own.

## If something says FAIL

- **SKIP** is not a failure — it always says why, and it is usually "nothing to test here yet".
- **`working tree dirty`** mid-work is the system counting unfinished work — normal until you
  approve a token.
- Any other **FAIL** names itself precisely. Don't hand-edit anything: open `claude` in that repo,
  paste the FAIL lines, and let it handle them under its own rules.

## Where things live

`GATES.md` — every approval you ever gave · `PROGRESS.md` — where work stands ·
`Plan.md` — the running log · `README.md` — the technical reference for everything above.
