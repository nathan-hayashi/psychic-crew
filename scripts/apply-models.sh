#!/usr/bin/env bash
# apply-models.sh — HC-4 single point: stamp model identity from models.config.json.
# Core logic per MASTER_FIFO_PLAN §5.5, with the EX-02 corrections recorded in Plan.md.
set -euo pipefail
cd "$(dirname "$0")/.."
CFG="models.config.json"
command -v jq >/dev/null || { echo "[FAIL] jq required"; exit 1; }

# EX-02(a): §5.5 pipes `grep -ril` (FILENAMES) into `grep -v forbidden_substrings`, so the
# filter tests the filename and never suppresses the legitimate declaration line — the check
# exits 2 on a clean repo. Match lines instead, and filter the declaration line.
for bad in $(jq -r '.forbidden_substrings[]' "$CFG"); do
  if grep -ri --exclude-dir=logs --exclude-dir=.git --exclude="MASTER_FIFO_PLAN_CLAUDE.md" \
       "$bad" .claude/ "$CFG" 2>/dev/null | grep -v '"forbidden_substrings"' | grep -q .; then
    echo "[FAIL] HC-2: forbidden model substring '$bad' present in config surface"; exit 2
  fi
done

MODE=$(jq -r '.mode // "alias"' "$CFG")

# EX-02(b): §5.5's `.[$m=="pinned" and "pinned" or "aliases"]` fails with "Cannot index object
# with boolean" — jq's and/or return booleans, not values. Use the same if/then/else idiom the
# per-agent line already uses.
SESSION_MODEL=$(jq -r --arg m "$MODE" \
  '.[if $m=="pinned" then "pinned" else "aliases" end][.session.model]' "$CFG")
[ -n "$SESSION_MODEL" ] && [ "$SESSION_MODEL" != "null" ] || {
  echo "[FAIL] session model unresolved for mode '$MODE'"; exit 4; }

jq --arg m "$SESSION_MODEL" '.model=$m' .claude/settings.json > .claude/settings.json.tmp \
  && mv .claude/settings.json.tmp .claude/settings.json
echo "[OK] session -> $SESSION_MODEL (mode:$MODE)"

# EX-02(c): §5.5 runs the agent loop as `jq ... | while read`, which executes in a subshell —
# its `exit 3` on a malformed frontmatter would kill only the subshell and the script would
# still report success, silently violating HC-4. Iterate without the pipeline.
for a in $(jq -r '.agents | keys[]' "$CFG"); do
  MODEL=$(jq -r --arg m "$MODE" --arg a "$a" \
    '.[if $m=="pinned" then "pinned" else "aliases" end][.agents[$a].model]' "$CFG")
  F=".claude/agents/$a.md"
  [ -f "$F" ] || { echo "[WARN] $F missing (created in F3)"; continue; }
  if grep -q '^model:' "$F"; then
    sed -i.bak "s/^model:.*/model: $MODEL/" "$F" && rm -f "$F.bak"
  else
    echo "[FAIL] $F lacks a model: line in frontmatter"; exit 3
  fi
  echo "[OK] $a -> $MODEL (effort:$(jq -r --arg a "$a" '.agents[$a].effort' "$CFG") recorded)"
done
echo "[OK] apply-models complete."
echo "[NOTE] Per-agent effort support was CONFIRMED at F0 step 6 (frontmatter 'effort':"
echo "       low|medium|high|xhigh|max, overrides session effort). F1 owns stamping it"
echo "       alongside model; §5.5's session-level fallback note is now moot."
