---
description: Run the test suite, analyze failures, suggest fixes
---
<!-- Chapter 3. Not printed in the book: written to its description at ch03:221. -->

Run the test suite with `npm test`. For each failing test:
1. Name the test and quote the assertion that failed
2. Read the test and the code it covers
3. Say why it fails, with file:line references
4. Suggest a fix to the code

Follow the testing conventions in CLAUDE.md. Fix the code, never the test,
unless I say the test itself is wrong.
If every test passes, say so in one sentence.
