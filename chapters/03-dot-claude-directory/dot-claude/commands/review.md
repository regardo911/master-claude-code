---
description: Run a focused code review on recent changes
---
<!-- Chapter 3 (ch03:198-211), verbatim from the book. -->

Review the staged changes in this project. Check for:
1. Type safety issues (any `any` types that should be specific)
2. Error handling (uncaught promises, missing try/catch)
3. Test coverage (new functions without corresponding tests)
4. Security (user input reaching queries without validation)

Show findings as a numbered list with file:line references.
If everything looks clean, say so in one sentence.
