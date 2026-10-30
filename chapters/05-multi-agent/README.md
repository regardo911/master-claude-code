# Chapter 5: /feature and MCP

Two commands go in `.claude/commands/`. `install.sh` already copied `feature.md`; copy `health-check.md` yourself if you have a deployed app.

| Command | What it hands back |
|---|---|
| `/feature add due dates to tasks` | a research subagent's findings, a Plan agent's plan, the built feature, a test run and a `/review` |
| `/health-check https://your-app.example.com` | health status, any errors, likely causes with file:line references, suggested fixes |

`feature.md` is ch05:124-152 as printed. `health-check.md` is ch05:215-235 with one line changed: the printed command never says which URL to check, so it now reads it from what you type after the command.

## Register an MCP server

Copied from ch05:189, 244-245 and 259-260. The Stripe, Sentry and Notion URLs from ch05:245 sit in a comment on the last line. Each registers one server at local scope, in `~/.claude.json`, private to you. Chapter 8 has the `--scope project` form for a team.

```bash
claude mcp add playwright -- npx -y @playwright/mcp@latest

claude mcp add db -- npx -y @bytebase/dbhub \
  --dsn "postgresql://taskflow:taskflow@localhost:5432/taskflow"

claude mcp add --transport http github https://api.githubcopilot.com/mcp/ --header "Authorization: Bearer YOUR_GITHUB_PAT"
claude mcp add --transport http <name> <url>    # Stripe https://mcp.stripe.com, Sentry https://mcp.sentry.dev/mcp, Notion https://mcp.notion.com/mcp
```

Swap the DSN for your own database. It needs a host and a port (ch05:273). If Playwright will not start, run `npx playwright install chromium` once (ch05:207).

Check it with `claude mcp list`, then `/mcp` inside a session. The book prints `playwright (stdio): npx -y @playwright/mcp@latest`; the exact line format can differ by Claude Code version, so look for the server name and a connected status.

## The CHECKPOINT (ch05:357)

Run `/feature` with a real request, for example the book's: "Add task priorities with values low, medium, high. Default to medium. Support sorting by priority on the list endpoint." You pass when the run finishes without you stepping in, the research step finds the right files, the plan makes sense, and the code follows your CLAUDE.md.

Cost and time per agent show up in your usage dashboard after the run (ch05:349). If one step burned more than you expected, the chapter's fix is a tighter scope in the prompt: name the files, cap the output, rule out web tools (ch05:172-176).
