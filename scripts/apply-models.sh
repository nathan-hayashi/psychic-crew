#!/usr/bin/env bash
# apply-models.sh — HC-4 single point: stamp model identity from models.config.json.
# Core logic per MASTER_FIFO_PLAN §5.5, with the EX-02 corrections recorded in Plan.md.
set -euo pipefail
cd "$(dirname "$0")/.."
CFG="models.config.json"
command -v jq >/dev/null || { echo "[FAIL] jq required"; exit 1; }

# HC-2 guard. History: EX-02(a) first repaired §5.5's filename-vs-line bug in this check;
# EX-03 then replaced the whole scan with assignment-position matching (below), under which
# that bug is structurally impossible. Do not reintroduce a whole-file substring scan.
for bad in $(jq -r '.forbidden_substrings[]' "$CFG"); do
  # EX-03: assignment positions only (a bare substring scan flags the rule file documenting the
  # prohibition, and F2's model-guard.sh, which must contain the string to guard it).
  # Captured into a variable rather than tested via pipeline status: under `set -o pipefail` a
  # non-matching inner grep exits 1 and would mark the whole pipeline failed, silently skipping
  # this guard entirely. Caught by the G-F1 stress test.
  HITS=$( { jq -r --arg b "$bad" '
              [ (.aliases // {} | to_entries[] | "aliases.\(.key)=\(.value)"),
                (.pinned  // {} | to_entries[] | "pinned.\(.key)=\(.value)"),
                ("session.model=" + (.session.model // "")),
                (.agents  // {} | to_entries[] | "agents.\(.key).model=\(.value.model)") ]
              | .[] | select(ascii_downcase | contains($b))' "$CFG" 2>/dev/null || true
            grep -rniE "^[[:space:]]*[\"']?model[\"']?[[:space:]]*:[[:space:]]*[\"']?[^\"',}]*${bad}" \
              .claude/ 2>/dev/null || true ; } | grep . || true )
  if [ -n "$HITS" ]; then
    echo "[FAIL] HC-2: forbidden model substring '$bad' assigned -> $(echo "$HITS" | tr '\n' ' ')"
    exit 2
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
  # F1: per-agent effort support was confirmed at F0 step 6 (documented frontmatter field,
  # low|medium|high|xhigh|max, overrides session effort). Stamp it alongside model.
  EFFORT=$(jq -r --arg a "$a" '.agents[$a].effort' "$CFG")
  if grep -q '^effort:' "$F"; then
    sed -i.bak "s/^effort:.*/effort: $EFFORT/" "$F" && rm -f "$F.bak"
  else
    sed -i.bak "/^model:/a effort: $EFFORT" "$F" && rm -f "$F.bak"
  fi
  echo "[OK] $a -> model:$MODEL effort:$EFFORT"
done
echo "[OK] apply-models complete."
echo "[OK] model and effort both stamped from the single source of truth (HC-4)."
