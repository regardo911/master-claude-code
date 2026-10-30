// Chapter 4 (ch04:347-378), as printed in the book.
// tests/auth.test.ts
import { describe, it, expect, beforeAll } from 'vitest'
import request from 'supertest'
import { app } from '../src/app'

describe('POST /auth/register', () => {
  it('creates a new user and returns tokens', async () => {
    const res = await request(app)
      .post('/auth/register')
      .send({ email: 'test@example.com', password: 'secure123' })

    expect(res.status).toBe(201)
    expect(res.body.data.accessToken).toBeDefined()
    expect(res.body.data.refreshToken).toBeDefined()
    expect(res.body.error).toBeNull()
  })

  it('rejects duplicate email', async () => {
    await request(app)
      .post('/auth/register')
      .send({ email: 'dupe@example.com', password: 'secure123' })

    const res = await request(app)
      .post('/auth/register')
      .send({ email: 'dupe@example.com', password: 'other456' })

    expect(res.status).toBe(409)
    expect(res.body.error).toBe('Email already registered')
  })
})
