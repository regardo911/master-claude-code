#!/usr/bin/env bash
# install.sh: put the book's .claude/ setup into a project you name.
#
#   ./install.sh ~/path/to/your-project
#   ./install.sh --template solo ~/path/to/your-project
#
# What goes in, and from which chapter:
#   .claude/CLAUDE.md          chapter 3 TaskFlow file (or Appendix B solo with --template solo)
#   .claude/commands/          review, test, scaffold (ch3), feature (ch5), security-audit (ch7)
#   .claude/memory/            MEMORY.md + one decision file (ch3; left out with --template solo,
#                              because the solo CLAUDE.md has no memory import)
#   .claude/settings.json      the chapter 7 hardened file: 14 allowed, 11 denied, credential hook.
#                              (takes the place of the chapter 3 one, per ch07:196)
#
# never overwrites: an existing file prints "kept:" and stays as it was (.gitignore gets one line appended).
# no flag for this, on purpose. settings.json is the last file a script should touch
#
# needs bash. the credential hook it installs needs jq (ch07:134)

set -eu

HERE=$(cd "$(dirname "$0")" && pwd)
usage() { echo "usage: ./install.sh [--template solo] <your-project-dir>" >&2; exit 2; }

TEMPLATE=taskflow
if [ "${1:-}" = "--template" ]; then
  [ "${2:-}" = "solo" ] || usage
  TEMPLATE=solo
  shift 2
fi
[ $# -eq 1 ] || usage
[ -d "$1" ] || { echo "install.sh: no such folder: $1" >&2; usage; }
PROJECT=$(cd "$1" && pwd)
SHOWN=$PROJECT
case "$PROJECT" in "$HOME"/*) SHOWN="~${PROJECT#"$HOME"}" ;; esac

if [ "$TEMPLATE" = solo ]; then
  CLAUDE_MD=appendix-b-starter-kit/solo/dot-claude/CLAUDE.md.example
else
  CLAUDE_MD=chapters/03-dot-claude-directory/dot-claude/CLAUDE.md.example
fi

# source (relative to this repo) -> destination (relative to the project)
FILES="$CLAUDE_MD .claude/CLAUDE.md
chapters/03-dot-claude-directory/dot-claude/commands/review.md .claude/commands/review.md
chapters/03-dot-claude-directory/dot-claude/commands/test.md .claude/commands/test.md
chapters/03-dot-claude-directory/dot-claude/commands/scaffold.md .claude/commands/scaffold.md
chapters/05-multi-agent/dot-claude/commands/feature.md .claude/commands/feature.md
chapters/07-production-hardening/dot-claude/commands/security-audit.md .claude/commands/security-audit.md"
if [ "$TEMPLATE" = taskflow ]; then
  FILES="$FILES
chapters/03-dot-claude-directory/dot-claude/memory/MEMORY.md .claude/memory/MEMORY.md
chapters/03-dot-claude-directory/dot-claude/memory/api-design-decisions.md .claude/memory/api-design-decisions.md"
fi

echo "Installing into $SHOWN"
echo "$FILES" | while read -r src dest; do
  if [ -e "$PROJECT/$dest" ]; then
    echo "  kept:   $dest"
  else
    mkdir -p "$(dirname "$PROJECT/$dest")"
    cp "$HERE/$src" "$PROJECT/$dest"
    echo "  copied: $dest"
  fi
done

SETTINGS=$HERE/chapters/07-production-hardening/dot-claude/settings.json
if [ -e "$PROJECT/.claude/settings.json" ]; then
  echo "  kept:   .claude/settings.json"
  echo "          merge by hand from $SETTINGS:"
  echo "          the 11 deny entries, the 14 allow entries, and the PostToolUse credential hook"
elif ! command -v jq >/dev/null 2>&1; then
  cp "$SETTINGS" "$PROJECT/.claude/settings.json"
  echo "  copied: .claude/settings.json (chapter 7)"
  echo "  jq is missing. The credential hook needs it: brew install jq / apt-get install jq / choco install jq"
elif [ -f "$PROJECT/package.json" ] && jq -e '.scripts.lint' "$PROJECT/package.json" >/dev/null 2>&1; then
  # ch03 lint hook, fixed: runs your lint script as is (ch04:133). the printed --fix makes tsc fail
  jq '.hooks.PostToolUse += [{"matcher": "Edit|Write", "hooks": [{"type": "command", "command": "npm run lint"}]}]' \
    "$SETTINGS" > "$PROJECT/.claude/settings.json"
  echo "  copied: .claude/settings.json (chapter 7, plus the chapter 3 lint hook: package.json has a lint script)"
else
  cp "$SETTINGS" "$PROJECT/.claude/settings.json"
  echo "  copied: .claude/settings.json (chapter 7; lint hook left out: no lint script in package.json)"
fi

if git -C "$PROJECT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [ -f "$PROJECT/.gitignore" ] && grep -qxF '.claude/settings.local.json' "$PROJECT/.gitignore"; then
    echo "  kept:   .gitignore (already lists .claude/settings.local.json)"
  else
    # a .gitignore that ends without a newline would glue our line onto its last one
    if [ -s "$PROJECT/.gitignore" ] && [ -n "$(tail -c 1 "$PROJECT/.gitignore")" ]; then
      echo >> "$PROJECT/.gitignore"
    fi
    echo '.claude/settings.local.json' >> "$PROJECT/.gitignore"
    echo "  added:  .claude/settings.local.json to .gitignore (ch03:451)"
  fi
fi

if [ "$TEMPLATE" = taskflow ]; then
  echo
  echo "CLAUDE.md and memory/ describe TaskFlow, the chapter 4 app. Rewrite them for your project (ch03 BUILD STEP 2)."
fi
echo
echo "Next:"
echo "  cd $SHOWN && claude"
echo "  then type /review"
