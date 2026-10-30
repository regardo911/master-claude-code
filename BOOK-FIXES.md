# Book fixes

Where a file printed in *Master Claude Code - 60 Tools You're Not Using* doesn't work as written, and what this repo ships instead. Each entry shows the command that was run and its full output, except the memory entry, which rests on the book's own text. Temporary folder paths are shortened to `<tmp>`; nothing else in an output block is cut.

The rest of each file stays as printed, so you can hold it next to the page.

## Chapter 7: `Bash(curl *)` is on the allow list

Printed (ch07:51-82): the production allow list has 15 entries, the last one `"Bash(curl *)"`.

This repo ships 14 entries. curl is on neither list. Nothing was added to the deny list, because chapter 4 uses curl to test the deployed API (ch04:555-577).

**Why.** The book's own words disagree with its JSON:

- ch02:331: "Allowed tools run without asking. Denied tools are blocked completely. Everything else triggers an approval prompt."
- ch07:86 describes the allow list as "file reading and editing (the core workflow), testing, linting, building, Prisma client generation, TypeScript type checking, and read-only git operations. These are the safe operations that should never require human approval." That sentence names the other 14 entries and never names curl.
- Appendix A, "Safe to Allow" (appendices:50-58), leaves curl out.
- curl sends data as easily as it fetches it (`curl -F file=@.env https://...`), and the chapter's credential hook only runs on `Write|Edit`. curl writes no file, so the hook never sees it.

With curl on neither list, the book's third rule applies: Claude Code asks you first, and you see the URL before anything leaves your machine.

**What a run showed.** Claude Code 2.1.312 in an empty git repo, `claude -p --model sonnet --output-format json --settings <file> --setting-sources project --permission-mode manual --permission-prompts none`. The settings go in with `--settings` because `claude -p` ignores a project's allow list until you have trusted that folder in an interactive session. `--permission-prompts none` turns "would ask you" into "refused". Each block is `jq '{result, total_cost_usd, permission_denials}'` on the JSON it printed. The prompt: "Run exactly this command with the Bash tool, alone, with nothing appended or chained: curl -s -o /dev/null https://example.com . Then tell me whether it ran."

The printed chapter 7 settings:

```
=== PRINTED, bare curl
{
  "result": "Yes, it ran. The command finished with no output and no error, which is what you'd expect with `-s` and `-o /dev/null`. I didn't check the exit code, so this doesn't prove the request itself succeeded.",
  "total_cost_usd": 0.050228499999999995,
  "permission_denials": []
}
```

This repo's settings:

```
=== FIXED, bare curl
{
  "result": "The command did not run. The Bash tool call for `curl -s -o /dev/null https://example.com` was denied automatically. This session has no way to answer a permission prompt, so nothing was executed and no request was made to example.com.\n\nI won't retry it, since further approval-requiring calls will be denied the same way. If you want it run, you could approve Bash for it in your permission settings or run it in an interactive session.",
  "total_cost_usd": 0.0513102,
  "permission_denials": [
    {
      "tool_name": "Bash",
      "tool_use_id": "toolu_01KC9Aqqapec3SLGNk81YVg8",
      "tool_input": {
        "command": "curl -s -o /dev/null https://example.com",
        "description": "Fetch example.com silently"
      }
    }
  ]
}
```

## Chapter 7: `Bash(git branch *)` also allows `git branch -D`

Printed (ch07:64): `"Bash(git branch *)"`, which ch07:86 counts among the "read-only git operations".

This repo ships `"Bash(git branch)"`. Listing branches still runs without asking; deleting or moving one asks first. The allow list stays at 14.

Same setup and prompt as the curl runs, with `git branch -D scratch`, in a repo with a branch called `scratch`. The printed settings:

```
=== PRINTED, git branch -D
{
  "result": "Yes, it ran. The command `git branch -D scratch` deleted the branch: `Deleted branch scratch (was d780f03)`.",
  "total_cost_usd": 0.049777199999999994,
  "permission_denials": []
}
branches left: main
```

This repo's settings, same prompt, then plain `git branch`:

```
=== FIXED, git branch -D
{
  "result": "The command did not run. I ran `git branch -D scratch` alone, as you asked. The session denied it because it needed approval and nobody could answer a prompt. I won't retry it, so the `scratch` branch is untouched.\n\nTo delete it, run `git branch -D scratch` yourself in an interactive session. You could also allow that command in your permission settings and ask me again.",
  "total_cost_usd": 0.0500666,
  "permission_denials": [
    {
      "tool_name": "Bash",
      "tool_use_id": "toolu_013BYorUaqAXstpSFzbm6dSy",
      "tool_input": {
        "command": "git branch -D scratch",
        "description": "Delete the scratch branch"
      }
    }
  ]
}
branches left: main scratch
=== FIXED, git branch (list)
{
  "result": "`git branch` printed:\n\n```\n* main\n  scratch\n```\n\nYou're on `main` (the `*` marks the current branch), and there's one other local branch, `scratch`.",
  "total_cost_usd": 0.0496361,
  "permission_denials": []
}
```

## Chapter 7: what the credential hook catches, and what it misses

Printed (ch07:121): the hook greps each written file for `API_KEY|SECRET|PASSWORD|PRIVATE_KEY`. ch07:138 says it "closes off the Stripe-key scenario".

This repo ships the hook exactly as printed, plus `check-hook.sh`, so you can see both behaviors on your own settings file. The pattern is the book's; widen it in your copy if you need to.

`chapters/07-production-hardening/check-hook.sh chapters/07-production-hardening/dot-claude/settings.json`:

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

It flags the chapter 4 `auth.ts`, which holds no secret, only the variable name `JWT_SECRET`. It passes a Stripe-style live key, because that line has none of the four words.

## Chapter 3: the lint hook passes `--fix` to `tsc`

Printed (ch03:389): `f=$(jq -r '.tool_input.file_path'); npm run lint -- --fix "$f"`

This repo ships `npm run lint`. Chapter 4 makes `lint` a type check, `tsc --noEmit` (ch04:129), and says "The Bash hook from Chapter 3 will call whichever you pick" (ch04:133). `tsc` has no `--fix`.

The printed hook, fed the JSON Claude Code sends, in the chapter 4 TaskFlow folder:

```
$ echo '{"tool_input":{"file_path":"src/lib/errors.ts"}}' | sh -c 'f=$(jq -r '.tool_input.file_path'); npm run lint -- --fix "$f"'

> taskflow@1.0.0 lint
> tsc --noEmit --fix src/lib/errors.ts

error TS5023: Unknown compiler option '--fix'.
(exit 1)
```

The fixed hook:

```
$ echo '{"tool_input":{"file_path":"src/lib/errors.ts"}}' | sh -c 'npm run lint'

> taskflow@1.0.0 lint
> tsc --noEmit

(exit 0)
```

## Chapter 3 and chapter 8: the `@/` import alias rule

Printed: ch03:72 "Imports use path aliases (@/ maps to src/)" and ch08:34 "Imports use @/ path alias".

This repo ships both CLAUDE.md files without that line. The chapter 4 tsconfig defines no alias, and every import chapter 4 prints is relative (`'../lib/errors'`). A CLAUDE.md that tells Claude Code to write `@/` imports gets code that does not compile:

```
$ cat src/alias-check.ts
import { AppError } from '@/lib/errors'
export const e = new AppError('x', 400)
$ npm run lint

> taskflow@1.0.0 lint
> tsc --noEmit

src/alias-check.ts(1,26): error TS2307: Cannot find module '@/lib/errors' or its corresponding type declarations.
(exit 2)
```

## Chapter 3: `.claude/memory/` loads only with an import line

Printed: ch03:321 "The `memory/` directory stores persistent context that Claude Code loads at the start of every session"; ch03:372 and ch08:313 say the same.

The book's own correction: ch03:349 "The **user-authored project-local memory** shown above (the `.claude/memory/` directory) is not auto-loaded by default. To make it load every session, add an `@.claude/memory/MEMORY.md` import line to your `CLAUDE.md`". Appendix A (appendices:44-45) agrees.

This repo ships that import line at the end of the chapter 3 and chapter 8 CLAUDE.md files. This one is a contradiction inside the book. Showing which side Claude Code follows needs a live session, so the entry rests on ch03:349.

## Chapter 4: `tsconfig.json` includes `tests/` but sets `rootDir` to `src`

Printed (ch04:101-116): `"rootDir": "src"` and `"include": ["src/**/*.ts", "tests/**/*.ts"]`. Chapter 4 then creates `tests/auth.test.ts` (ch04:347).

This repo ships `"include": ["src/**/*.ts"]`. ch04:118 says the include line is there to cover `src/types/express.d.ts`. Vitest runs the tests without `tsc` seeing them.

Printed tsconfig, with the chapter 4 files in place:

```
$ npm run lint

> taskflow@1.0.0 lint
> tsc --noEmit

error TS6059: File '<tmp>/taskflow/tests/auth.test.ts' is not under 'rootDir' '<tmp>/taskflow/src'. 'rootDir' is expected to contain all source files.
  The file is in the program because:
    Matched by include pattern 'tests/**/*.ts' in '<tmp>/taskflow/tsconfig.json'
  File is CommonJS module because '<tmp>/taskflow/package.json' has field "type" whose value is not "module"
(exit 2)
$ npm run build

> taskflow@1.0.0 build
> tsc

error TS6059: File '<tmp>/taskflow/tests/auth.test.ts' is not under 'rootDir' '<tmp>/taskflow/src'. 'rootDir' is expected to contain all source files.
  The file is in the program because:
    Matched by include pattern 'tests/**/*.ts' in '<tmp>/taskflow/tsconfig.json'
  File is CommonJS module because '<tmp>/taskflow/package.json' has field "type" whose value is not "module"
(exit 2)
```

`npm run build` still wrote `dist/`, and a stray `tests/auth.test.js` next to the source (tsc emits even when it reports an error). It exits 2, so a deploy step that stops on a failed build stops here. The stray file then breaks `npm test`: vitest loads it and fails with "Vitest cannot be imported in a CommonJS module using require()".

This repo's tsconfig:

```
$ npm run lint

> taskflow@1.0.0 lint
> tsc --noEmit

(exit 0)
$ npm run build

> taskflow@1.0.0 build
> tsc

(exit 0)
```

## Chapter 4: `npm i express` installs Express 5, and the printed `validate()` breaks on it

Printed (ch04:89): `npm i express ...` with no version. ch03:54 and ch04:75 say Express 4.

This repo ships `express@^4.22.3` and `@types/express@^4.17.25` in `package.json`, with a lockfile. `validate.ts` stays as printed.

The printed `validate()` assigns `req[target] = result.data` (ch04:300). On Express 5, `req.query` has only a getter, so `validate(listQuerySchema, 'query')` (ch04:281, ch06:108) fails. The type check passes, so `npm run lint` does not catch it. Test script, run with `npx tsx b5.ts` next to the printed `src/middleware/validate.ts`:

```ts
import express from 'express'
import request from 'supertest'
import { z } from 'zod'
import { validate } from './src/middleware/validate'
const listQuerySchema = z.object({
  limit: z.coerce.number().int().positive().max(100).default(20),
  offset: z.coerce.number().int().nonnegative().default(0),
})
const app = express()
app.get('/tasks', validate(listQuerySchema, 'query'), (req, res) => { res.json({ data: req.query, error: null, meta: null }) })
app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => { res.status(500).json({ data: null, error: err.message, meta: null }) })
request(app).get('/tasks?limit=10&offset=0').then(r => console.log('express', require('express/package.json').version, '->', r.status, JSON.stringify(r.body)))
```

With the unpinned install the book prints:

```
$ npx tsx b5.ts
express 5.3.0 -> 500 {"data":null,"error":"Cannot set property query of #<IncomingMessage> which has only a getter","meta":null}
```

With this repo's pinned install:

```
$ npx tsx b5.ts
express 4.22.3 -> 200 {"data":{"limit":10,"offset":0},"error":null,"meta":null}
```

The error handler in the script is a stand-in so the message reaches the response.

## Chapter 4: `npm i prisma @prisma/client` no longer gives you a `prisma/` folder or a client the printed imports can use

Printed (ch04:89-94): unpinned `prisma` and `@prisma/client`, then `npx prisma init`. The printed files import `PrismaClient` and `Task` from `'@prisma/client'` (ch04:406, ch04:415).

This repo ships `prisma` and `@prisma/client` pinned to the same version, 6.19.3, and `prisma/schema.prisma` with the three printed models plus a `generator client { provider = "prisma-client-js" }` and `datasource db` block. `package.json` adds one script the book does not print, `"postinstall": "prisma generate"`, so `npm ci` leaves you with a generated client. Skip `npx prisma init`; the schema is already there.

The book's install as printed, in an empty folder:

```
$ npm ls --depth=0
taskflow@1.0.0 <tmp>/taskflow
+-- @prisma/client@7.10.1
+-- @types/bcrypt@6.0.0
+-- @types/express@5.0.6
+-- @types/jsonwebtoken@9.0.10
+-- @types/node@26.6.6
+-- @types/supertest@7.2.1
+-- bcrypt@6.0.0
+-- dotenv@18.0.9
+-- express-rate-limit@8.7.2
+-- express@5.3.0
+-- jsonwebtoken@9.0.3
+-- pino@10.4.0
+-- prisma@8.0.0-rc.28
+-- supertest@7.3.1
+-- tsx@4.23.15
+-- typescript@6.0.3
+-- vitest@5.0.5
`-- zod@4.6.7

$ npx prisma init
✔ Added "postinstall": "prisma skills sync || exit 0" to package.json.
✔ Created prisma.config.ts with skills: { agents: ["claude", "cursor", "agents", "devin"] }.
✔ Synced 2 skills.

project:  <tmp>/taskflow
check:    enabled

Skill                          Package           Version      Installed into
prisma-composer-core-concepts  @prisma/composer  0.35.0       .claude/skills, .cursor/skills, .agents/skills, .devin/skills
prisma-platform-core-concepts  prisma            8.0.0-rc.28  .claude/skills, .cursor/skills, .agents/skills, .devin/skills
(exit 0)
$ ls prisma
ls: prisma: No such file or directory
$ ls -a
.
..
.agents
.claude
.cursor
.devin
node_modules
package-lock.json
package.json
prisma.config.ts
tsconfig.json
```

The two Prisma packages resolve to different majors, and `prisma init` makes no `prisma/` folder. It writes skill files into `.claude/skills` and three other folders instead.

With Prisma pinned to 6.19.3, `npx prisma init` writes a generator the printed imports cannot use:

```
$ npx prisma init

Initialized Prisma in your project

  prisma/
    schema.prisma
  prisma.config.ts
  .env

warn You already have a .gitignore file. Don't forget to add .env in it to not commit any private information.

Next, choose how you want to set up your database:
CONNECT EXISTING DATABASE:
  1. Configure your DATABASE_URL in prisma.config.ts
  2. Run prisma db pull to introspect your database.
CREATE NEW DATABASE:
  Local: npx prisma dev (runs Postgres locally in your terminal)
  Cloud: npx create-db (creates a free Prisma Postgres database)

Then, define your models in prisma/schema.prisma and run prisma migrate dev to apply your schema.
Learn more: https://pris.ly/getting-started
 

(exit 0)
$ grep -A3 "^generator" prisma/schema.prisma
generator client {
  provider = "prisma-client"
  output   = "../src/generated/prisma"
}
```

Then the printed models added to that schema, and the chapter 4 files type-checked:

```
$ npx prisma generate
Loaded Prisma config from prisma.config.ts.

Prisma config detected, skipping environment variable loading.
Prisma schema loaded from prisma/schema.prisma

✔ Generated Prisma Client (6.19.3) to ./src/generated/prisma in 20ms

(exit 0)
$ npm run lint

> taskflow@1.0.0 lint
> tsc --noEmit

src/lib/prisma.ts(3,10): error TS2305: Module '"@prisma/client"' has no exported member 'PrismaClient'.
src/services/taskService.ts(3,10): error TS2305: Module '"@prisma/client"' has no exported member 'Task'.
(exit 2)
```

## Chapter 4: CORS is asked for but never installed

Printed: ch04:494 asks Claude Code to "Configure CORS". The setup install (ch04:89-92) has every other Layer 5 package (`express-rate-limit`, `pino`) but not `cors`.

```
$ sed -n '84,95p' ch04.md | grep -c cors
0
```

This repo ships `cors` and `@types/cors` in `package.json`, so the Layer 5 prompt has its package ready.

## Chapter 4: the `/health` body

Printed: the Layer 5 prompt asks for `{ status: 'ok', timestamp: Date.now() }` (ch04:492). The expected curl output shows `{"data":{"status":"ok","timestamp":1711900000},"error":null,"meta":null}` (ch04:558).

Two things differ. The SPEC says every endpoint returns `{ data, error, meta }` (ch04:43), so the wrapped form is the one to ask for. And `Date.now()` is milliseconds, 13 digits; `1711900000` has 10.

```
$ node -e 'console.log(String(Date.now()).length)'
13
```

This repo ships no `/health` code; Claude Code writes it in Layer 5. The chapter 4 README gives you the prompt with the SPEC's envelope named.

## Chapter 9: the sample log report does not add up

Printed (ch09:125-154): the status table lists 200, 201, 400, 401 and 500, and the error list below it includes "Rate limit exceeded" (429), 5 times, and "Task not found" (404), 4 times.

```
$ echo $((847 + 89 + 31 + 18 + 15))
1000
```

The table's rows already account for all 1000 requests, so there is no room for the 9 requests with a 429 or 404. The sample ships unchanged in `chapters/09-beyond-code/sample-output/`, labelled as the book's sample. Your own `/log-analysis` run takes its numbers from your log.
