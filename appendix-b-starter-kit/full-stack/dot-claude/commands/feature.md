---
description: Build a new feature using research-plan-build pipeline
---
<!-- Appendix B, full-stack (appendices:356-369), verbatim from the book. -->
Build the following feature: $ARGUMENTS

1. Scan the codebase for relevant patterns (both client and server)
   using a read-only research subagent
2. Plan the implementation (API changes, frontend components, database schema)
3. Build backend first (schema, service, route, tests)
4. Build frontend second (components, API calls, tests)
5. Verify shared types are consistent
6. Run full test suite
