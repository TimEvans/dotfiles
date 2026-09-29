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

# --- Bead binding: title and status come from bd, not story frontmatter ---
# A constellation vault has no stories/*.md. The binding's vault carries a
# .beads dir, so focus-info asks bd for the card and caches the answer; the
# statusline must never wait on bd inline (starship kills slow commands).
TMP=$(mktemp -d)
SID="bead-session"
PROJDIR="$TMP/.claude/projects/-home-tim-Github-cc-plugins"
VAULT="$TMP/vault"
mkdir -p "$PROJDIR" "$VAULT/.beads" "$TMP/bin"
echo "{\"story\":\"mgrs-g1n.6\",\"repo\":\"cc-plugins\",\"since\":\"x\",\"vault\":\"$VAULT\"}" >"$PROJDIR/$SID.binding.json"

# Fake bd: records each call, answers like `bd show <id> --json`.
cat >"$TMP/bin/bd" <<'FAKE'
#!/usr/bin/env bash
echo "$BEADS_DIR $*" >>"$FAKE_BD_LOG"
[ -n "${FAKE_BD_FAIL:-}" ] && exit 1
printf '[{"id":"mgrs-g1n.6","title":"Fix bead-ID grammar in timekeeper","status":"in_progress"}]\n'
FAKE
chmod +x "$TMP/bin/bd"
export FAKE_BD_LOG="$TMP/bd.log"

run_focus() {
  (cd /tmp && HOME="$TMP" XDG_RUNTIME_DIR="$TMP/run" PATH="$TMP/bin:$PATH" \
    CLAUDE_SESSION_ID="" CLAUDE_CODE_SESSION_ID="$SID" bash "$SCRIPT" "$@")
}

# First call: nothing cached yet, must answer immediately with the bare id.
out=$(run_focus label)
if [ "$out" = "mgrs-g1n.6" ]; then
  pass "bead label falls back to the id before the cache is warm"
else
  bad "expected bare id on cold cache, got '$out'"
fi

# Give the background refresh a moment to land.
for _ in 1 2 3 4 5 6 7 8 9 10; do
  [ -s "$TMP/run/focus-info/mgrs-g1n.6.json" ] && break
  sleep 0.1
done

out=$(run_focus label)
if [ "$out" = "mgrs-g1n.6 - Fix bead-ID grammar in timekeeper" ]; then
  pass "bead label shows the bd title once cached"
else
  bad "expected bd title in label, got '$out'"
fi

out=$(run_focus status)
if [ "$out" = "in_progress" ]; then
  pass "bead status comes from bd"
else
  bad "expected 'in_progress', got '$out'"
fi

if run_focus check in_progress; then
  pass "check compares against the bd status"
else
  bad "check should succeed for in_progress"
fi

calls=$(wc -l <"$FAKE_BD_LOG")
if [ "$calls" = "1" ]; then
  pass "bd is called once while the cache is fresh"
else
  bad "expected 1 bd call, got $calls"
fi

if grep -q "^$VAULT/.beads show mgrs-g1n.6 --json" "$FAKE_BD_LOG"; then
  pass "bd is pointed at the binding's vault"
else
  bad "bd was not pointed at the vault: $(cat "$FAKE_BD_LOG")"
fi

# --- Binding hint: focus writes title + status into the binding, so the card
#     renders on the first redraw with no bd cache at all ---
rm -rf "$TMP/run/focus-info"
: >"$FAKE_BD_LOG"
echo "{\"story\":\"mgrs-g1n.6\",\"repo\":\"cc-plugins\",\"since\":\"x\",\"vault\":\"$VAULT\",\"title\":\"Fix bead-ID grammar in timekeeper\",\"status\":\"in_progress\"}" >"$PROJDIR/$SID.binding.json"
# bd is made to fail here so no cache can ever form: the values must come
# from the binding alone.
export FAKE_BD_FAIL=1
out=$(run_focus label)
if [ "$out" = "mgrs-g1n.6 - Fix bead-ID grammar in timekeeper" ]; then
  pass "label uses the binding's title before any bd cache exists"
else
  bad "expected binding title on cold cache, got '$out'"
fi
out=$(run_focus status)
if [ "$out" = "in_progress" ]; then
  pass "status uses the binding's status before any bd cache exists"
else
  bad "expected binding status on cold cache, got '$out'"
fi
unset FAKE_BD_FAIL

# --- Newer binding beats older cache: ship flips the binding to closed while
#     the cache, seconds old, still says in_progress ---
rm -rf "$TMP/run/focus-info"
run_focus label >/dev/null
for _ in 1 2 3 4 5 6 7 8 9 10; do
  [ -s "$TMP/run/focus-info/mgrs-g1n.6.json" ] && break
  sleep 0.1
done
CACHE="$TMP/run/focus-info/mgrs-g1n.6.json"
touch -d '10 seconds ago' "$CACHE"
sed -i 's/"status":"in_progress"/"status":"closed"/' "$PROJDIR/$SID.binding.json"
out=$(run_focus status)
if [ "$out" = "closed" ]; then
  pass "a binding newer than the cache wins"
else
  bad "expected 'closed' from the newer binding, got '$out'"
fi

# --- Stale lock: a refresh that died must not block refreshes forever ---
CACHE="$TMP/run/focus-info/mgrs-g1n.6.json"
# Let the refresh kicked off by the previous call finish first, or its late
# mv would replace the aged cache with a fresh one mid-test.
for _ in 1 2 3 4 5 6 7 8 9 10; do
  [ ! -d "$CACHE.lock" ] && break
  sleep 0.1
done
touch -d '2 minutes ago' "$CACHE"
mkdir -p "$CACHE.lock" && touch -d '2 minutes ago' "$CACHE.lock"
: >"$FAKE_BD_LOG"
run_focus label >/dev/null
for _ in 1 2 3 4 5 6 7 8 9 10; do
  [ -s "$FAKE_BD_LOG" ] && break
  sleep 0.1
done
calls=$(wc -l <"$FAKE_BD_LOG")
if [ "$calls" = "1" ]; then
  pass "a stale lock is swept and the refresh runs"
else
  bad "expected 1 bd call after stale lock, got $calls"
fi

rm -rf "$TMP"
exit $fail
