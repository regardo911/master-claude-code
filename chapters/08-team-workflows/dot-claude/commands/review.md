---
description: Team code review checklist
---
<!-- Chapter 8 (ch08:104-117), the team version of /review, verbatim from the book. -->
Review the staged changes. Check for:
1. Type safety (no 'any' types, explicit return types)
2. Error handling (all async calls wrapped, AppError used)
3. Test coverage (new functions have corresponding tests)
4. Security (no raw SQL, user input validated with Zod, auth checks on protected routes)
5. Convention compliance (file placement, naming, import style)
6. Scope (only files related to the stated task are modified)

Report each check as PASS or FAIL with specific file:line references.
