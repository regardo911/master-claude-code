# Chapter 3: the .claude/ directory

`dot-claude/` is the chapter 3 build, finished: the TaskFlow CLAUDE.md, three commands, the settings file and a memory folder. In your project it is called `.claude/`.

```bash
./install.sh ~/your-project          # from the repo root
```

`install.sh` copies everything here except `settings.json`; in this repo chapter 7's file takes its place (ch07:196 has you copy that permission set into `.claude/settings.json`). It takes this folder's lint hook along when your `package.json` has a `lint` script. To copy this chapter's files by hand instead, with `-n` so nothing of yours is overwritten:

```bash
mkdir -p ~/your-project/.claude
cp -Rn dot-claude/commands dot-claude/memory ~/your-project/.claude/
cp -n dot-claude/CLAUDE.md.example ~/your-project/.claude/CLAUDE.md
cp -n dot-claude/settings.json ~/your-project/.claude/settings.json
```

| File | From the book | |
|---|---|---|
| `CLAUDE.md.example` | ch03:50-120, the five blocks in order | minus the `@/` alias line, plus the memory import line ([why](../../BOOK-FIXES.md)) |
| `commands/review.md` | ch03:198-211 | as printed |
| `commands/scaffold.md` | ch03:239-249 | as printed; run it as `/scaffold users` |
| `commands/test.md` | ch03:221 describes it; it is not printed | written to that description |
| `memory/MEMORY.md` | ch03:327 describes the index | one line, pointing at the file below |
| `memory/api-design-decisions.md` | ch03:333-347 | as printed |
| `settings.json` | permissions ch03:261-282, hook ch03:380-396 | 12 allowed, 4 denied; the hook runs `npm run lint` with no `--fix` ([why](../../BOOK-FIXES.md)) |

## Did it work?

The chapter's own check (ch03:445): start `claude` in your project and ask for a new feature. Does the output follow your conventions without a reminder, land in the right folders, and run the tests? Three yeses and the configuration is working.

Then make it yours. Every line of `CLAUDE.md` and `memory/` describes TaskFlow, the chapter 4 app. Rewrite the project identity, the structure and the decisions for your own code, keep it under 100 lines (ch03:134), and add one memory file per decision worth keeping, 5 to 15 in all (ch03:372). Each new memory file gets one line in `memory/MEMORY.md`, because that index is the only part the import line loads.

## Where each setting lives

![Where each setting lives, as a table of file, who it applies to, and whether it goes in git. .claude/settings.json: everyone on the project, yes. .claude/settings.local.json: only you, no. ~/.claude/settings.json: you, in every project, no. .mcp.json, from claude mcp add --scope project: everyone on the project, yes. ~/.claude.json, from claude mcp add: only you, no. A deny in any settings file wins over an allow in another.](../../docs/images/where-settings-live.png)

`install.sh` adds `.claude/settings.local.json` to your `.gitignore` when the project is a git repo, so your own overrides stay yours (ch03:451).

The lint hook type-checks the whole project after every edit, because `tsc --noEmit` has no single-file mode that honors your tsconfig. On a big project that gets slow, and ch03:410 tells you to keep hooks fast. If it drags, take the hook out of `settings.json` and run `/test` instead.
