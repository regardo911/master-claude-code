// Chapter 4 (ch04:322-331), as printed in the book.
// src/app.ts - Express app, no listener (importable by tests)
import express from 'express'
import { errorHandler } from './middleware/errors'

export const app = express()
app.use(express.json())
// route mounts go here (auth, tasks, tags)
app.use(errorHandler)
