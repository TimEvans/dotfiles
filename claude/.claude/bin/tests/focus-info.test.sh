#!/usr/bin/env bash
# Tests for focus-info.sh binding resolution.
# Run: bash claude/.claude/bin/tests/focus-info.test.sh
set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/focus-info.sh"
fail=0

pass() { echo "PASS: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# --- Binding resolves by session ID, independent of PWD ---
# Simulates the post-S135 worktree case: the binding lives under the session's
# original cwd slug, but the shell PWD is a worktree with a different slug.
TMP=$(mktemp -d)
SID="test-session-xyz"
PROJDIR="$TMP/.claude/projects/-home-tim-Github-somerepo"
mkdir -p "$PROJDIR"
echo '{"story":"S136","repo":"timekeeper","since":"x"}' >"$PROJDIR/$SID.binding.json"

out=$(cd /tmp && HOME="$TMP" CLAUDE_SESSION_ID="" CLAUDE_CODE_SESSION_ID="$SID" bash "$SCRIPT" label)
if [ "$out" = "S136" ]; then
  pass "label resolves binding by session id when PWD diverges"
else
  bad "expected 'S136', got '$out'"
fi

# check action should succeed in finding a binding (exit 0 path needs a story)
# --- No binding present: graceful fallback ---
out=$(cd /tmp && HOME="$TMP" CLAUDE_SESSION_ID="" CLAUDE_CODE_SESSION_ID="no-such-session" bash "$SCRIPT" label)
if [ "$out" = "What are we working on?" ]; then
  pass "no-binding label falls back gracefully"
else
  bad "expected fallback label, got '$out'"
fi

rm -rf "$TMP"
exit $fail
