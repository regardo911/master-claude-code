// Chapter 4. Not printed in the book: app.ts imports `errorHandler` from here
// (ch04:325), so this is the least that compiles. It answers in the SPEC's
// { data, error, meta } shape (ch04:43). Claude Code writes the real one in Layer 1.
import { Request, Response, NextFunction } from 'express'
import { AppError } from '../lib/errors'

export function errorHandler(
  err: Error, _req: Request, res: Response, _next: NextFunction
): void {
  const status = err instanceof AppError ? err.status : 500
  res.status(status).json({ data: null, error: err.message, meta: null })
}
