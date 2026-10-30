// Chapter 4 (ch04:238-259), as printed in the book.
// src/middleware/auth.ts
import jwt from 'jsonwebtoken'
import { Request, Response, NextFunction } from 'express'
import { AppError } from '../lib/errors'

export function authMiddleware(
  req: Request, _res: Response, next: NextFunction
): void {
  const token = req.headers.authorization?.split(' ')[1]
  if (!token) {
    throw new AppError('No token provided', 401)
  }
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!)
    req.user = payload as { id: string; email: string }
    next()
  } catch {
    throw new AppError('Invalid token', 401)
  }
}
