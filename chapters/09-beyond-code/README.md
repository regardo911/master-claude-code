# Chapter 9: commands for work outside code

Five automations from the chapter, as command files. Copy the ones you will use into `.claude/commands/`. The book names only `morning-check.md`; the other four names are ours, so rename them if you like, since the file name is the slash command.

| Command | You give it | It writes | Needs |
|---|---|---|---|
| `/morning-check` | `DASHBOARD_URL` and the login in your environment | `reports/morning-check.md` | Playwright MCP |
| `/e2e-test [url]` | the app URL; empty means `http://localhost:3000` | a PASS/FAIL line per step | Playwright MCP, a frontend |
| `/log-analysis [path]` | a log file; empty means `logs/production.log` | `reports/log-analysis.md` | nothing beyond Claude Code |
| `/competitor-pricing` | `data/competitors.json`, a list of URLs you keep | `reports/pricing-alert.md`, an updated `data/pricing-history.json` | Playwright MCP |
| `/weekly-report <client>` | a client name | `reports/weekly/<client>-<date>.md` and an email draft | the db MCP, Playwright MCP |

`e2e-test.md` and `log-analysis.md` each differ from the print in step 1, which now takes your input and falls back to the printed URL or path. The other three are as printed (ch09:27-45, 224-239, 273-305).

Playwright needs a browser on the machine once: `npx playwright install chromium`, about 150 MB (ch09:49). The MCP lines are in the [chapter 5 README](../05-multi-agent/README.md).

Start with `/log-analysis`. It needs no browser and no account, only a log file, so it is the quickest way to see one of these work end to end.

`sample-output/log-analysis.md` is the report the book prints for `/log-analysis`, so you can see the shape before your first run. It did not come from this repo, and its status table cannot be right ([BOOK-FIXES.md](../../BOOK-FIXES.md)).

The chapter's bar (ch09:375): the command finishes without you stepping in, and you would actually read what it wrote.
