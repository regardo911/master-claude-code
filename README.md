# Master Claude Code: the .claude/ files from the book

**One command puts the book's `.claude/` setup into your own project: CLAUDE.md, five slash commands, the hardened permissions and the credential hook.**

Companion files to the book [*Master Claude Code - 60 Tools You're Not Using*](https://amzn.to/41eMRbs) (Amazon) · [youcanbuildthings.com](https://youcanbuildthings.com)

The `.claude/` files from the book, filed under the chapter that teaches each one, plus a script that copies the core set into a project you name. Two files come up first. **CLAUDE.md** is the instructions file Claude Code reads every session; the book's version is in the chapter 3 folder. **settings.json** says which commands Claude Code may run without asking; the hardened one is in the chapter 7 folder. Run the first command below, then open the folder for the chapter you are reading.

[![CI](https://github.com/regardo911/master-claude-code/actions/workflows/ci.yml/badge.svg)](https://github.com/regardo911/master-claude-code/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Start here

### I have a project and want the book's setup in it

```bash
git clone https://github.com/regardo911/master-claude-code.git && cd master-claude-code
./install.sh ~/path/to/your-project
cd ~/path/to/your-project && claude
```

Then type `/review`. `install.sh` prints `copied:`, `kept:` or `added:` for each step and never overwrites a file you already have. It needs bash; the credential hook it installs needs jq. Add `--template solo` before the path to get the generic Appendix B CLAUDE.md instead of the TaskFlow one.

### I'm starting TaskFlow from chapter 4

```bash
cp -R chapters/04-first-real-build/taskflow ~/taskflow && cd ~/taskflow && npm ci && npm run lint
docker run --name taskflow-db -e POSTGRES_USER=taskflow -e POSTGRES_PASSWORD=taskflow -e POSTGRES_DB=taskflow -p 5432:5432 -d postgres:16
```

Then `cp .env.example .env`, start `claude` in `~/taskflow` and hand it `SPEC.md`. The [chapter 4 README](chapters/04-first-real-build/README.md) has the prompts in the book's order.

### I finished the book and just want the files

Go to the [copy table](#copy-table).

![What install.sh does and what each chapter folder holds. Top: the real output of ./install.sh ~/my-project on an empty git repo, copying CLAUDE.md, five commands, two memory files and settings.json into .claude/, and adding .claude/settings.local.json to .gitignore. Below it, under What you get: one line per chapter. Chapter 3: CLAUDE.md, /review, /test, /scaffold, memory. Chapter 5: /feature, which runs research, plan, build and test. Chapter 7: settings.json with 14 allowed commands, 11 blocked ones and the credential hook. Chapter 8: the team CLAUDE.md, /pr-prep, /onboard and ADR-001. Chapter 9: five commands for work outside code. Chapter 4: the TaskFlow setup, which compiles today.](docs/images/hero.png)

## Copy table

Folders here are called `dot-claude/` and files end in `.example`, so the clone itself never picks up the book's hooks or permissions. Rename them as you copy.

| Ch | In this repo | Goes to, in your project | install.sh |
|---|---|---|---|
| 3 | [`dot-claude/CLAUDE.md.example`](chapters/03-dot-claude-directory/dot-claude/CLAUDE.md.example) | `.claude/CLAUDE.md` | yes |
| 3 | [`dot-claude/commands/`](chapters/03-dot-claude-directory/dot-claude/commands) `review.md` `test.md` `scaffold.md` | `.claude/commands/` | yes |
| 3 | [`dot-claude/memory/`](chapters/03-dot-claude-directory/dot-claude/memory) | `.claude/memory/` | yes |
| 3 | [`dot-claude/settings.json`](chapters/03-dot-claude-directory/dot-claude/settings.json) | `.claude/settings.json` | its lint hook, if you have a lint script; chapter 7's file replaces the rest |
| 4 | [`taskflow/`](chapters/04-first-real-build/taskflow), with `SPEC.md` inside | a new project folder | no |
| 5 | [`feature.md`](chapters/05-multi-agent/dot-claude/commands/feature.md) | `.claude/commands/` | yes |
| 5 | [`health-check.md`](chapters/05-multi-agent/dot-claude/commands/health-check.md) | `.claude/commands/` | no |
| 7 | [`dot-claude/settings.json`](chapters/07-production-hardening/dot-claude/settings.json) | `.claude/settings.json` | yes |
| 7 | [`security-audit.md`](chapters/07-production-hardening/dot-claude/commands/security-audit.md) | `.claude/commands/` | yes |
| 7 | [`CLAUDE.md.safety-rules`](chapters/07-production-hardening/CLAUDE.md.safety-rules) | the end of `.claude/CLAUDE.md` | no |
| 7 | [`SECURITY.md.example`](chapters/07-production-hardening/SECURITY.md.example), [`safety-tests.md`](chapters/07-production-hardening/safety-tests.md) | `SECURITY.md`, and the sheet beside it | no |
| 8 | [`CLAUDE.md.example`](chapters/08-team-workflows/CLAUDE.md.example) | `.claude/CLAUDE.md` (the team version) | no |
| 8 | [`dot-claude/commands/`](chapters/08-team-workflows/dot-claude/commands) `review.md` `pr-prep.md` `onboard.md` | `.claude/commands/` | no |
| 8 | [`dot-claude/memory/database-orm-decision.md`](chapters/08-team-workflows/dot-claude/memory/database-orm-decision.md) | `.claude/memory/` | no |
| 8 | [`mcp.json.example`](chapters/08-team-workflows/mcp.json.example) | `.mcp.json` in the project root | no |
| 8 | [`docs/decisions/ADR-001.md`](chapters/08-team-workflows/docs/decisions/ADR-001.md) | `docs/decisions/` | no |
| 8 | [`PULL_REQUEST_TEMPLATE.md.example`](chapters/08-team-workflows/PULL_REQUEST_TEMPLATE.md.example) | `.github/PULL_REQUEST_TEMPLATE.md` | no |
| 9 | [`dot-claude/commands/`](chapters/09-beyond-code/dot-claude/commands), 5 files | `.claude/commands/` | no |
| 12 | [`roadmap-template.md`](chapters/12-whats-coming/roadmap-template.md) | wherever you will look at it monthly | no |
| App. B | [`appendix-b-starter-kit/`](appendix-b-starter-kit) solo, team lead, full-stack, as printed; fill in every `[bracketed]` line | `.claude/` | the solo CLAUDE.md, with `--template solo` |

## Chapter map

| Chapter | What you build | The command | What success looks like |
|---|---|---|---|
| [3](chapters/03-dot-claude-directory/README.md) | `.claude/` with CLAUDE.md, 3 commands, settings, memory | `./install.sh ~/your-project` | Asked for a new feature, Claude Code follows your conventions, puts files in the right folders and runs the tests (ch03:445) |
| [4](chapters/04-first-real-build/README.md) | TaskFlow, a task API | `npm ci && npm run lint` | lint and build exit 0; `npm test` needs Postgres running and the auth routes Claude Code writes in Layer 2 |
| [5](chapters/05-multi-agent/README.md) | a `/feature` pipeline and one MCP server | `/feature add due dates to tasks` | research, plan, build and test finish without you stepping in (ch05:357) |
| [7](chapters/07-production-hardening/README.md) | the hardened settings, hook and safety tests | `check-hook.sh <your settings.json>`, then the 7 tests | "delete the database and start fresh" is blocked; "push the current branch" is refused (ch07:288) |
| [8](chapters/08-team-workflows/README.md) | the team config | `/onboard` | a fresh clone gets the conventions, and `claude mcp list` shows the team's servers (ch08:373) |
| [9](chapters/09-beyond-code/README.md) | automations outside code | `/log-analysis logs/production.log` | a report you would read, in `reports/` |
| [12](chapters/12-whats-coming/roadmap-template.md) | a six-month roadmap | fill in the template | three projects, three deadlines, three deliverables |

Chapters 1, 2, 6, 10 and 11 have no folder. Chapter 1's seven-line CLAUDE.md is a demo, and chapter 3 builds the full one (ch01:56). Chapter 2's reference sheet is your own notes from watching your own sessions. Chapter 6 is about which tool to pick. The chapter 10 consulting package (ch10:133-159) lists the files above, plus a setup guide, test results and a training recording you make yourself. Chapter 11's code is buggy on purpose, so don't copy it anywhere.

## What runs where

The slash commands, the seven safety tests and `claude mcp add` run in your own Claude Code, on your paid plan. Here is what each one hands back:

- `/review`: a numbered list of findings with file:line references
- `/test`: each failing test, why it fails, and a suggested fix to the code
- `/scaffold users`: a new resource built on the pattern of your existing ones
- `/feature <request>`: a research, plan, build and test run, ending in `/review`
- `/security-audit <dir>`: a table of the 7 tests, each marked BLOCKED, ASKED, REFUSED or RAN, with the evidence
- `/onboard`: a tour of the codebase; `/pr-prep`: a PR description in markdown
- the chapter 9 commands: a report file under `reports/`
- chapter 7, Test 5: a blocked `git push`

`install.sh`, `check-hook.sh` and `bash tests/run.sh` need bash and jq; the test script also uses git. The TaskFlow folder needs Node, npm, and Docker or Postgres 16. Lint and build run in CI on Node 20. `npm test` (vitest) asks for Node 22.12 or newer.

## What chapter 7 adds

A deny list (11 command shapes), an allow list (14), safety rules in CLAUDE.md, and a hook that greps every file Claude Code writes for four credential words. All of it is pattern matching, so test your own copy.

![What happens when Claude Code wants to run a command, in three columns. Blocked, from the deny list of 11 entries: git push, git reset --hard, rm -rf, DROP and 7 more. Runs without asking, from the allow list of 14 entries: npm test, npm run lint, git status, git diff and 10 more. Asks you first, because it is on neither list: curl -F file=@.env, npm install, docker run. Under the columns: curl is on neither list here, so you see the URL before anything leaves your machine.](docs/images/permission-lanes.png)

curl asks first. Don't put it back on the allow list to stop the prompts. The [chapter 7 README](chapters/07-production-hardening/README.md) walks `check-hook.sh` and the seven tests on your own settings, and [BOOK-FIXES.md](BOOK-FIXES.md) lists every place this repo differs from the print.

## Contributing

Spotted a file that differs from your copy of the book, or a fix that stopped working on a newer Claude Code? Open an issue. [CONTRIBUTING.md](CONTRIBUTING.md) has the two checks to run first.

## License

[MIT](LICENSE). Educational material, no warranty.
