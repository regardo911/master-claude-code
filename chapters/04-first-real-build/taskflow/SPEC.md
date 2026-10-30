<!-- Chapter 4 (ch04:19-47), verbatim from the book. -->

# TaskFlow Spec

## Stack
- Express.js + TypeScript
- PostgreSQL + Prisma ORM
- JWT authentication (access + refresh tokens)
- Zod input validation
- Vitest for testing

## Resources
- Users: register, login, refresh token
- Tasks: CRUD operations scoped to authenticated user
- Tags: create, list, assign to tasks (many-to-many)

## Structure
- src/routes/ (one file per resource)
- src/services/ (business logic per resource)
- src/middleware/ (auth, error handling, validation)
- src/lib/ (shared utilities, types, and config)
- prisma/ (schema and migrations)
- tests/ (mirrors src/ structure)

## Behavior
- All endpoints return JSON with shape { data, error, meta }
- Auth required on all /tasks and /tags endpoints
- Pagination on list endpoints (limit/offset query params)
- Soft delete on tasks (isDeleted flag, not actual DELETE)
