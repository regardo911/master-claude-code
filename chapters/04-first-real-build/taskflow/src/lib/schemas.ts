// Chapter 4 (ch04:454-464), as printed in the book.
// src/lib/schemas.ts (excerpt)
import { z } from 'zod'

export const CreateTaskSchema = z.object({
  title: z.string().min(1).max(200),
  description: z.string().optional(),
})

export type CreateTaskInput = z.infer<typeof CreateTaskSchema>
