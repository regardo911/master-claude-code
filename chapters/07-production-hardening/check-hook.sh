#!/usr/bin/env bash
# check-hook.sh: run the command hooks in YOUR settings.json on test files, and print what they did.
#
#   chapters/07-production-hardening/check-hook.sh ~/your-project/.claude/settings.json
#   chapters/07-production-hardening/check-hook.sh ~/your-project/.claude/settings.json src/config.ts
#
# ch07 test 2 needs a live session. this answers the part a shell can:
# given a file, what exit code and message does your hook give
#
# Each hook gets the JSON Claude Code sends on stdin (ch03:400):
#   {"tool_input":{"file_path":"<file>"}}
# With no files named, it uses three:
#   test_secrets.txt   API_KEY=sk_test_fake123          (the ch07:150 fixture)
#   auth.ts            the chapter 4 auth middleware     (reads process.env.JWT_SECRET)
#   stripe-key.ts      const k = "sk_live_51Hxx..."      (a Stripe-style key, no keyword)
# Hooks run under bash, from the folder above .claude/ when the settings file sits in one.
# It reports what the hook did. Whether that is the behavior you want is your call.

set -u

HERE=$(cd "$(dirname "$0")" && pwd)
[ $# -ge 1 ] || { echo "usage: check-hook.sh <settings.json> [file ...]" >&2; exit 2; }
SETTINGS=$1; shift
[ -f "$SETTINGS" ] || { echo "check-hook.sh: no such file: $SETTINGS" >&2; exit 2; }
if ! command -v jq >/dev/null 2>&1; then
  echo "check-hook.sh: jq is not installed, and your hooks need it too (ch07:134)." >&2
  echo "  macOS: brew install jq   Debian/Ubuntu: apt-get install jq   Windows: choco install jq" >&2
  exit 2
fi
jq empty "$SETTINGS" 2>/dev/null || { echo "check-hook.sh: $SETTINGS is not valid JSON" >&2; exit 2; }

SETTINGS_DIR=$(cd "$(dirname "$SETTINGS")" && pwd)
case "$SETTINGS_DIR" in
  */.claude) RUN_IN=$(dirname "$SETTINGS_DIR") ;;
  *) RUN_IN=$SETTINGS_DIR ;;
esac

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
if [ $# -eq 0 ]; then
  echo "API_KEY=sk_test_fake123" > "$TMP/test_secrets.txt"
  cp "$HERE/../04-first-real-build/taskflow/src/middleware/auth.ts" "$TMP/auth.ts"
  echo 'const k = "sk_live_51Hxx..."' > "$TMP/stripe-key.ts"
  set -- "$TMP/test_secrets.txt" "$TMP/auth.ts" "$TMP/stripe-key.ts"
fi

# one line per command hook: event <TAB> group index <TAB> hook index <TAB> matcher.
# The command itself is read separately, so quotes and backslashes in it survive.
jq -r '(.hooks // {}) | to_entries[] | select(.key == "PreToolUse" or .key == "PostToolUse")
       | .key as $ev | .value | to_entries[] | .key as $g | (.value.matcher // "*") as $m
       | (.value.hooks // []) | to_entries[] | select(.value.type == "command")
       | [$ev, ($g|tostring), (.key|tostring), $m] | @tsv' "$SETTINGS" > "$TMP/hooks.tsv"

if [ ! -s "$TMP/hooks.tsv" ]; then
  echo "No PreToolUse or PostToolUse command hooks in $SETTINGS."
  echo "(A flat hook, with \"command\" right under the matcher, does not count: ch07:130.)"
  exit 0
fi

n=0
while IFS="$(printf '\t')" read -r event g h matcher; do
  n=$((n + 1))
  cmd=$(jq -r --arg ev "$event" --argjson g "$g" --argjson h "$h" '.hooks[$ev][$g].hooks[$h].command' "$SETTINGS")
  echo "hook $n: $event, matcher \"$matcher\""
  echo "  $cmd"
  for f in "$@"; do
    abs=$(cd "$(dirname "$f")" && pwd)/$(basename "$f")
    out=$(cd "$RUN_IN" && printf '{"tool_input":{"file_path":"%s"}}' "$abs" | bash -c "$cmd" 2>"$TMP/err")
    code=$?
    printf '  %-18s exit %s\n' "$(basename "$f")" "$code"
    [ -n "$out" ] && printf '%s\n' "$out" | sed 's/^/      stdout: /'
    [ -s "$TMP/err" ] && sed 's/^/      stderr: /' "$TMP/err"
  done
  echo
done < "$TMP/hooks.tsv"

echo "Exit 2 is the code the book's hook uses to flag a file (ch07:132)."
echo "Whether Claude Code showed the warning in your session: unknown, you must observe this (Test 2, safety-tests.md)."
