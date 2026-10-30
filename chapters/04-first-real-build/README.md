# Chapter 4: TaskFlow, the first real build

You build TaskFlow by asking Claude Code for it, layer by layer. `taskflow/` is where the chapter starts: the setup the book has you type (pinned, so it still compiles), the files the book prints as examples of what Claude Code writes, and the [SPEC.md](taskflow/SPEC.md) you hand it.

Copy it out of this clone first, so your build gets its own folder and its own git history:

```bash
cp -R taskflow ~/taskflow && cd ~/taskflow
git init
npm ci
npm run lint
npm run build
```

Expected: `npm ci` prints `✔ Generated Prisma Client (v6.19.3)`, then npm's audit and script warnings. The other two print their script line (`> tsc --noEmit`, `> tsc`) and exit 0. `npm run build` writes `dist/`.

Then the database and your env file, as ch04:137-157 has them:

```bash
cp .env.example .env
docker run --name taskflow-db -e POSTGRES_USER=taskflow -e POSTGRES_PASSWORD=taskflow -e POSTGRES_DB=taskflow -p 5432:5432 -d postgres:16
npx prisma migrate dev --name init
```

Skip `npx prisma init` from ch04:94. `prisma/schema.prisma` is already here, and a current Prisma would write a different one. `npm audit` flags high-severity advisories in the pinned Prisma 6.19.3 (`deepmerge-ts`, via `@prisma/config`); npm's fix is a major Prisma upgrade, which this repo hasn't tried.

## What is in `taskflow/`

- Typed by you in the book, and pinned here: `package.json` (the ch04:122-131 scripts, plus `postinstall`), `package-lock.json`, `tsconfig.json`, `.env.example`, `.gitignore`. Express 4, Prisma 6.19.3 for both packages, and `cors`, which Layer 5 asks for.
- Printed in the book, unchanged: `src/middleware/auth.ts`, `src/types/express.d.ts`, `src/middleware/validate.ts`, `src/app.ts`, `src/index.ts`, `src/lib/prisma.ts`, `src/services/taskService.ts`, `src/lib/schemas.ts`, `tests/auth.test.ts`, and the three models in `prisma/schema.prisma`.
- Written here so the printed files compile: `src/lib/errors.ts` (`AppError`) and `src/middleware/errors.ts` (`errorHandler`). The book names both and prints neither. Let Claude Code replace them in Layer 1.

[BOOK-FIXES.md](../../BOOK-FIXES.md) shows each change against the print, with the failing output.

## The prompts, in the book's order

Put the chapter 3 setup in first: `./install.sh ~/taskflow` from the repo root. It adds the chapter 3 lint hook, because `package.json` has a `lint` script. Then, in `claude`:

1. "Read SPEC.md and set up the project. Start with the database schema and the project structure. Don't write route handlers yet." (ch04:67)
2. Layer 1. Ask for error handling middleware that returns the `{ data, error, meta }` shape, auth middleware that validates JWTs, and Zod validation middleware (ch04:231-234). The book prints the auth and validation files, so those are in `src/`; the error handler is a short stand-in. Have Claude Code check all three against your CLAUDE.md.
3. Layer 2: "Build the auth routes: POST /register, POST /login, POST /refresh. Use bcrypt for password hashing. Return JWT access and refresh tokens." (ch04:312)
4. "Write tests for the auth routes. Cover registration with valid data, registration with duplicate email, login with correct credentials, and login with wrong password." (ch04:343)
5. Layer 3: "Build CRUD endpoints for tasks. All routes require authentication. List supports pagination with limit/offset. Delete is a soft delete (set isDeleted flag)." (ch04:396)
6. Layer 4: "Build tag endpoints: POST /tags, GET /tags, POST /tasks/:id/tags. Many-to-many relationship between tasks and tags." (ch04:476)
7. Layer 5, one at a time:
   - "Add rate limiting to POST /register and POST /login. Maximum 5 requests per minute per IP. Return 429 with a message telling the user to wait." (ch04:488)
   - "Add request logging middleware that logs the HTTP method, path, status code, and response time for every request. Use pino for structured JSON logging." (ch04:490)
   - "Add a GET /health endpoint that returns 200 with { status: 'ok', timestamp: Date.now() }." (ch04:492) Add "inside the SPEC's { data, error, meta } shape", which is what the book's own curl output shows.
   - "Configure CORS to allow requests from http://localhost:3000 in development and from the production frontend URL. Don't use wildcard (*) in production." (ch04:494)
8. "Set up a Dockerfile for this project. Configure it for Railway deployment with a PostgreSQL addon. Make sure environment variables are read from the environment, not from .env files in production." (ch04:536)

Run `/review` and `/test` after each layer (ch04:592).

`npm test` needs the database running and the auth routes from step 3. Until Claude Code has written them, both tests in `tests/auth.test.ts` fail with `expected 404 to be 201` and `expected 404 to be 409`.

## Done when

The chapter's CHECKPOINT (ch04:596): against your deployed URL you can register, log in, create a task, list tasks and add a tag, and every response comes back as `{ data, error, meta }`.
