---
name: API design decisions
description: Key architectural decisions for the TaskFlow API
type: project
---
<!-- Chapter 3 (ch03:333-347), verbatim from the book. -->

We chose Prisma over Drizzle because the team has more experience
with Prisma and the migration system is better suited to our
deployment pipeline.

REST over GraphQL because our frontend team prefers explicit
endpoints and the data shapes are simple enough that GraphQL's
flexibility adds complexity without benefit.
