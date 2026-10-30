// Chapter 4 (ch04:404-409), as printed in the book.
// src/lib/prisma.ts - shared Prisma client (import this everywhere)
import { PrismaClient } from '@prisma/client'

export const prisma = new PrismaClient()
