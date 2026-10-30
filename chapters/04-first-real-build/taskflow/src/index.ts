// Chapter 4 (ch04:333-339), as printed in the book.
// src/index.ts - server entry point (binds port; never imported by tests)
import { app } from './app'

const port = Number(process.env.PORT ?? 3000)
app.listen(port, () => console.log(`TaskFlow listening on ${port}`))
