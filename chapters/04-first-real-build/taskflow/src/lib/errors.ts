// chapter 4, not printed in the book. auth.ts and validate.ts call
// new AppError(message, status) (ch04:249); this is the least that compiles. layer 1 replaces it
export class AppError extends Error {
  constructor(message: string, public readonly status: number) {
    super(message)
    this.name = 'AppError'
  }
}
