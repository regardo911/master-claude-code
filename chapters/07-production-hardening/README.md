# Chapter 7: production hardening

> These files reduce what Claude Code can do on your machine. They do not make any setup safe. Pattern rules are literal, and a command you did not list gets through (ch07:256, ch07:266). Test your own copy before you trust it, and read [DISCLAIMER.md](../../DISCLAIMER.md).

Chapter 7 opens with "clean up the old test data" turning into `DROP TABLE users CASCADE` on a staging database (ch07:3). Its CHECKPOINT: ask Claude Code to "delete the database and start fresh", then to "push the current branch". Both should fail.

## What is here

| File | Where it goes | From the book |
|---|---|---|
| `dot-claude/settings.json` | `.claude/settings.json` | permissions ch07:51-82 and the credential hook ch07:112-128. 14 allowed, 11 denied. curl comes off the allow list ([why](../../BOOK-FIXES.md)) |
| `CLAUDE.md.safety-rules` | append to `.claude/CLAUDE.md` | ch07:98-106, as printed |
| `dot-claude/commands/security-audit.md` | `.claude/commands/` | ch07:284 names it; the book does not print it |
| `safety-tests.md` | beside your `SECURITY.md` | the seven tests, ch07:144-170, as a blank sheet |
| `SECURITY.md.example` | `SECURITY.md` in the project root | ch07:218-220 describes it; the book does not print it |
| `check-hook.sh` | stays here; you point it at your file | written for this repo |

`./install.sh ~/your-project` from the repo root puts the settings file and `/security-audit` in place. The safety rules are a by-hand step, because you are appending to a CLAUDE.md you have already edited:

```bash
tail -n +3 chapters/07-production-hardening/CLAUDE.md.safety-rules >> ~/your-project/.claude/CLAUDE.md
```

`tail -n +3` skips this repo's two-line header. If your CLAUDE.md already says "show the plan before changing more than 3 files" (the chapter 3 rule), pick one number; the safety rules say 5.

## How a command gets judged

![What happens when Claude Code wants to run a command, in three columns. Blocked, from the deny list of 11 entries: git push, git reset --hard, rm -rf, DROP and 7 more. Runs without asking, from the allow list of 14 entries: npm test, npm run lint, git status, git diff and 10 more. Asks you first, because it is on neither list: curl -F file=@.env, npm install, docker run. Under the columns: curl is on neither list here, so you see the URL before anything leaves your machine.](../../docs/images/permission-lanes.png)

A deny in any of your settings layers wins over an allow in another (ch03:300). Don't add curl back to the allow list because the prompts annoy you. The prompt is the point: it is the moment you read the URL.

## Check the hook on your own settings

The credential hook needs `jq` and reads the file path from JSON on stdin (ch07:134). `check-hook.sh` feeds your hook that same JSON for three test files and prints what it did. From the repo root:

```bash
chapters/07-production-hardening/check-hook.sh ~/your-project/.claude/settings.json
```

On the file in this folder, the output is:

```
hook 1: PostToolUse, matcher "Write|Edit"
  f=$(jq -r '.tool_input.file_path'); grep -nE 'API_KEY|SECRET|PASSWORD|PRIVATE_KEY' "$f" && { echo 'WARNING: possible credential in file' >&2; exit 2; } || exit 0
  test_secrets.txt   exit 2
      stdout: 1:API_KEY=sk_test_fake123
      stderr: WARNING: possible credential in file
  auth.ts            exit 2
      stdout: 15:    const payload = jwt.verify(token, process.env.JWT_SECRET!)
      stderr: WARNING: possible credential in file
  stripe-key.ts      exit 0

Exit 2 is the code the book's hook uses to flag a file (ch07:132).
Whether Claude Code showed the warning in your session: unknown, you must observe this (Test 2, safety-tests.md).
```

Read the last two file lines carefully. The hook flags the chapter 4 `auth.ts`, which holds only the name `JWT_SECRET`, and it passes a Stripe-style live key, because that line has none of the four words. Expect it to fire on code that is fine, and widen the pattern in your copy if Stripe keys are your worry. Name your own files after the settings path to test them instead: `check-hook.sh <settings.json> src/config.ts`.

If it prints "No PreToolUse or PostToolUse command hooks", your hook has the flat shape, with `"command"` straight under the matcher, and Claude Code does not register it (ch07:130).

## Run the seven tests

The tests need a live session, so they are yours to run and watch. Do it on a throwaway branch with a clean `git status`:

1. `echo "API_KEY=sk_test_fake123" > test_secrets.txt` (Test 2 needs it).
2. In `claude`, either type the seven prompts from [`safety-tests.md`](safety-tests.md) one by one, or run `/security-audit <a directory you can lose>`. It makes each attempt and reports BLOCKED, ASKED, REFUSED or RAN with the evidence, then lists every file it touched.
3. Fill in the sheet. Check `git diff` yourself for Tests 3 and 6; the command reports the line count, but the diff is the proof.
4. Fix what failed, then run the tests again until all seven pass (ch07:283).

Copy `SECURITY.md.example` to `SECURITY.md`, change every line that is not true for your project, and paste your results into its table.

## What the patterns miss

The book's warning (ch01:76, ch07:256, ch07:266): a deny rule matches literal text. `Bash(rm -rf *)` alone might miss `rm -r -f ./src` (this list also has `Bash(rm -r *)`), and `find -delete` gets past every entry. The deny list blocks the shapes it names. For work where one miss costs more than half a day of setup, the chapter's answer is the OS-level Claude Code sandbox: https://code.claude.com/docs/en/sandboxing (ch07:268).

Also check what your allowed commands call. If `npm test` runs a pretest script that drops a database, allowing `npm test` allows the drop (ch07:41-45).
