# Chapter 8: the team layer

A new developer clones your repo, opens `claude`, types `/onboard`, and gets a tour of the codebase with your conventions and boundaries already loaded. That is the chapter's goal (ch01:136). These are the files that get committed for it.

```
your-project/
├── .claude/
│   ├── CLAUDE.md                  ← CLAUDE.md.example (team version)
│   ├── settings.json              ← chapter 7's file, unchanged (ch08:69)
│   ├── commands/review.md         ← dot-claude/commands/review.md (replaces chapter 3's)
│   ├── commands/pr-prep.md        ← dot-claude/commands/pr-prep.md
│   ├── commands/onboard.md        ← dot-claude/commands/onboard.md
│   └── memory/database-orm-decision.md
├── .mcp.json                      ← mcp.json.example
├── docs/decisions/ADR-001.md
└── .github/PULL_REQUEST_TEMPLATE.md   ← PULL_REQUEST_TEMPLATE.md.example
```

Every file is the printed text (ch08:21-49, 104-147, 237-246, 275-295, 315-324), with two exceptions. The team `CLAUDE.md.example` drops the `@/` alias rule and gains the memory import line ([why](../../BOOK-FIXES.md)). `mcp.json.example` isn't printed; Claude Code wrote it (below). Copy them by hand; `install.sh` sets up one developer, and these are a team decision.

Two steps the files cannot do for you:

- Add a line for the decision file to `.claude/memory/MEMORY.md`, for example `- [Database ORM decision](database-orm-decision.md): Prisma, no raw SQL, see ADR-001`. The import line loads the index, and the index is what points at the file.
- Add `## Architecture Decisions` with `- See docs/decisions/ for ADRs` to the team CLAUDE.md, as the chapter 8 BUILD STEP 5 and the Appendix B team-lead template both do.

## Share the MCP servers

`claude mcp add` without `--scope project` writes to `~/.claude.json`, and your team never sees it (ch08:75). Register the shared ones like this (ch08:83-85, ch08:93):

```bash
claude mcp add --scope project playwright -- npx -y @playwright/mcp@latest
claude mcp add --scope project db -- npx -y @bytebase/dbhub --dsn '${DATABASE_URL}'
git add .mcp.json && git commit -m "Share the team's MCP servers"
```

The single quotes matter. With double quotes your shell expands `$DATABASE_URL` and writes your password into a file you are about to commit (ch08:90). `mcp.json.example` is the file those two lines wrote, run on Claude Code 2.1.312 in an empty repo. The `"${DATABASE_URL}"` in it is filled in from each developer's own environment when the server starts.

## Done when

From a fresh clone in a scratch folder, with no `settings.local.json` (ch08:369-373):

- `/onboard` gives a tour a new developer could start from,
- `/review` reports each of its six checks as PASS or FAIL with file:line references,
- and `claude mcp list` shows the team's servers without anyone re-adding them.
