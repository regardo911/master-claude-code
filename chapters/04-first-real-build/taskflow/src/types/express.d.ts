// Chapter 4 (ch04:263-277), as printed in the book.
// src/types/express.d.ts
declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string
        email: string
      }
    }
  }
}

export {}
