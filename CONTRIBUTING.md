# Contributing

Issues and pull requests are welcome. The ones that help most:

- a file here that differs from your printed copy of the book (say which chapter and line)
- a fix in [BOOK-FIXES.md](BOOK-FIXES.md) that stopped working on a newer Claude Code, npm package or Node version, with the output you got

Before you open a pull request, run both checks and paste the last lines:

```bash
bash tests/run.sh
cd chapters/04-first-real-build/taskflow && npm ci && npm run lint && npm run build
```

Keep the book's files as the book prints them. A change to one of them belongs in BOOK-FIXES.md, with the command that shows the printed version failing and its full output. Want to add a command the book doesn't teach? Do it in your fork.

Never commit a real key, token or `.env` file, even in a test.
