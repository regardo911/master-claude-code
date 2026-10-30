#!/usr/bin/env bash
# tests/run.sh: the repo's own checks. bash + jq, no network, no key.
#   bash tests/run.sh
# One ok/FAIL line per check, a count at the end, non-zero exit on any failure.

# The checks are strings passed to eval, so shellcheck cannot see the variables they read.
# shellcheck disable=SC2034,SC2016

set -u
cd "$(dirname "$0")/.." || exit 1
PASS=0; FAILS=0
ok()   { PASS=$((PASS + 1)); echo "ok    $1"; }
bad()  { FAILS=$((FAILS + 1)); echo "FAIL  $1"; }
check() { if eval "$2"; then ok "$1"; else bad "$1"; fi; }

command -v jq >/dev/null 2>&1 || { echo "FAIL  jq is not installed"; exit 1; }

# every file in the repo except installed packages and git internals
tracked() { find . \( -path ./.git -o -name node_modules \) -prune -o -type f -print; }

# --- JSON ---------------------------------------------------------------------
for f in $(tracked | grep -E '\.json(\.example)?$'); do
  check "parses: $f" "jq empty '$f' 2>/dev/null"
done

# --- nothing in this repo is live Claude Code config (README: the nesting rule) --
check "no .claude/ folder anywhere" "[ -z \"\$(find . -name node_modules -prune -o -type d -name .claude -print)\" ]"
check "no file named exactly CLAUDE.md" "[ -z \"\$(tracked | grep -E '/CLAUDE\.md$')\" ]"
check "no .mcp.json" "[ -z \"\$(tracked | grep -E '/\.mcp\.json$')\" ]"
check "no live .github/PULL_REQUEST_TEMPLATE.md" "[ ! -e .github/PULL_REQUEST_TEMPLATE.md ]"

# --- chapter 7 settings ------------------------------------------------------------
S7=chapters/07-production-hardening/dot-claude/settings.json
check "ch07 settings: 14 allow entries" "[ \"\$(jq '.permissions.allow | length' $S7)\" = 14 ]"
check "ch07 settings: 11 deny entries" "[ \"\$(jq '.permissions.deny | length' $S7)\" = 11 ]"
check "ch07 settings: curl is not on the allow list" "! jq -r '.permissions.allow[]' $S7 | grep -q '^Bash(curl'"
DENY='["Bash(git push *)","Bash(git push)","Bash(git reset --hard *)","Bash(git checkout -- *)","Bash(git clean *)","Bash(rm -rf *)","Bash(rm -r *)","Bash(drop *)","Bash(DROP *)","Bash(npx prisma migrate reset *)","Bash(npx prisma db push --force-reset)"]'
check "ch07 settings: deny list is the 11 entries printed at ch07:68-78" "[ \"\$(jq -c '.permissions.deny' $S7)\" = '$DENY' ]"
# ch07:121 exactly, as the JSON string decodes
HOOK='f=$(jq -r '"'"'.tool_input.file_path'"'"'); grep -nE '"'"'API_KEY|SECRET|PASSWORD|PRIVATE_KEY'"'"' "$f" && { echo '"'"'WARNING: possible credential in file'"'"' >&2; exit 2; } || exit 0'
check "ch07 settings: credential hook is the ch07:121 command, byte for byte" "[ \"\$(jq -r '.hooks.PostToolUse[0].hooks[0].command' $S7)\" = \"\$HOOK\" ]"
check "ch07 settings: hook is PostToolUse on Write|Edit, nested hooks array, type command" \
  "[ \"\$(jq -c '.hooks.PostToolUse[0] | [.matcher, .hooks[0].type]' $S7)\" = '[\"Write|Edit\",\"command\"]' ]"
check "ch03 settings: lint hook runs the lint script with no extra arguments" \
  "[ \"\$(jq -r '.hooks.PostToolUse[0].hooks[0].command' chapters/03-dot-claude-directory/dot-claude/settings.json)\" = 'npm run lint' ]"

# --- check-hook.sh -------------------------------------------------------------------
OUT=$(chapters/07-production-hardening/check-hook.sh $S7 2>&1)
check "check-hook.sh: test_secrets.txt exits 2" "echo \"\$OUT\" | grep -qE '^  test_secrets.txt +exit 2$'"
check "check-hook.sh: chapter 4 auth.ts exits 2" "echo \"\$OUT\" | grep -qE '^  auth.ts +exit 2$'"
check "check-hook.sh: sk_live line exits 0" "echo \"\$OUT\" | grep -qE '^  stripe-key.ts +exit 0$'"
check "check-hook.sh: prints the WARNING line from the hook" "echo \"\$OUT\" | grep -q 'stderr: WARNING: possible credential in file'"
check "check-hook.sh: never claims to know what your session showed" "echo \"\$OUT\" | grep -q 'unknown, you must observe this'"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
echo 'nothing to see' > "$T/clean.txt"
OUT2=$(chapters/07-production-hardening/check-hook.sh $S7 "$T/clean.txt" 2>&1)
check "check-hook.sh: takes your own file and reports on it" "echo \"\$OUT2\" | grep -qE '^  clean.txt +exit 0$'"
check "check-hook.sh: refuses with no argument" "! chapters/07-production-hardening/check-hook.sh >/dev/null 2>&1"

# --- install.sh ----------------------------------------------------------------------
sums() { (cd "$1" && find . -type f ! -path './.git/*' -exec cksum {} \; | sort); }
P="$T/project"; mkdir -p "$P"; git -C "$P" init -q
FIRST=$(./install.sh "$P" 2>&1); RC=$?
check "install.sh: exits 0 on an empty git repo" "[ \$RC -eq 0 ]"
for f in CLAUDE.md settings.json commands/review.md commands/test.md commands/scaffold.md commands/feature.md commands/security-audit.md memory/MEMORY.md memory/api-design-decisions.md; do
  check "install.sh: creates .claude/$f" "[ -f '$P/.claude/$f' ]"
done
check "install.sh: settings.json is the chapter 7 file" "cmp -s '$P/.claude/settings.json' $S7"
check "install.sh: adds .claude/settings.local.json to .gitignore" "grep -qxF .claude/settings.local.json '$P/.gitignore'"
check "install.sh: prints the next step" "echo \"\$FIRST\" | grep -q 'then type /review'"
BEFORE=$(sums "$P")
SECOND=$(./install.sh "$P" 2>&1)
check "install.sh: second run changes nothing" "[ \"\$BEFORE\" = \"\$(sums '$P')\" ]"
check "install.sh: second run prints kept: for all 8 files, settings.json and .gitignore" "[ \"\$(echo \"\$SECOND\" | grep -c 'kept:')\" -eq 10 ]"
check "install.sh: second run copies nothing" "! echo \"\$SECOND\" | grep -q 'copied:'"

Q="$T/has-settings"; mkdir -p "$Q/.claude"; echo '{"permissions":{"allow":["Bash(*)"]}}' > "$Q/.claude/settings.json"
cp "$Q/.claude/settings.json" "$T/orig.json"
./install.sh "$Q" > "$T/q.out" 2>&1
check "install.sh: leaves an existing settings.json byte-identical" "cmp -s '$Q/.claude/settings.json' '$T/orig.json'"
check "install.sh: tells you what to merge by hand" "grep -q 'merge by hand' '$T/q.out'"
check "install.sh: no .gitignore change outside a git repo" "[ ! -e '$Q/.gitignore' ]"

L="$T/with-lint"; mkdir -p "$L"; echo '{"scripts":{"lint":"tsc --noEmit"}}' > "$L/package.json"
./install.sh "$L" > /dev/null 2>&1
check "install.sh: adds the chapter 3 lint hook when package.json has a lint script" \
  "jq -r '.hooks.PostToolUse[].hooks[].command' '$L/.claude/settings.json' | grep -qx 'npm run lint'"
check "install.sh: keeps the credential hook alongside it" "[ \"\$(jq '.hooks.PostToolUse | length' '$L/.claude/settings.json')\" -eq 2 ]"

SOLO="$T/solo"; mkdir -p "$SOLO"
./install.sh --template solo "$SOLO" > /dev/null 2>&1
check "install.sh --template solo: uses the Appendix B solo CLAUDE.md" "cmp -s '$SOLO/.claude/CLAUDE.md' appendix-b-starter-kit/solo/dot-claude/CLAUDE.md.example"
check "install.sh --template solo: no memory folder" "[ ! -e '$SOLO/.claude/memory' ]"
check "install.sh: refuses with no argument" "! ./install.sh >/dev/null 2>&1"
check "install.sh: refuses a folder that does not exist" "! ./install.sh '$T/nope' >/dev/null 2>&1"

# --- links ----------------------------------------------------------------------------
for doc in $(tracked | grep -E '\.md$'); do
  dir=$(dirname "$doc")
  # links in prose only: code blocks and `inline code` hold examples, not links
  for link in $(awk '/^```/{c=!c; next} !c' "$doc" | sed 's/`[^`]*`//g' | grep -oE '\]\([^)#]+\)' | sed -E 's/^\]\(//; s/\)$//' | grep -vE '^(https?:|mailto:)'); do
    check "link in $doc: $link" "[ -e '$dir/$link' ]"
  done
done

# --- words ----------------------------------------------------------------------------
# The book calls a cost a "rece""ipt" in places; this repo never does. Split so this line does not match itself.
WORD="rece""ipt"
check "no file uses the word \$WORD" "[ -z \"\$(tracked | xargs grep -il \"\$WORD\" 2>/dev/null)\" ]"

TOTAL=$((PASS + FAILS))
echo
echo "$PASS passed, $FAILS failed, $TOTAL checks"
[ "$TOTAL" -gt 0 ] || { echo "FAIL  ran zero checks"; exit 1; }
[ "$FAILS" -eq 0 ]
