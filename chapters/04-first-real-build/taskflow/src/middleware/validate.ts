// Chapter 4 (ch04:283-304), as printed in the book.
// src/middleware/validate.ts
import { ZodSchema } from 'zod'
import { Request, Response, NextFunction } from 'express'
import { AppError } from '../lib/errors'

type ValidationTarget = 'body' | 'query' | 'params'

export function validate(
  schema: ZodSchema,
  target: ValidationTarget = 'body'
) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    const result = schema.safeParse(req[target])
    if (!result.success) {
      throw new AppError(result.error.issues[0].message, 400)
    }
    req[target] = result.data
    next()
  }
}
