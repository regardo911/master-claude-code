// Chapter 4 (ch04:413-448), as printed in the book.
// src/services/taskService.ts
import { Task } from '@prisma/client'
import { prisma } from '../lib/prisma'
import { CreateTaskInput } from '../lib/schemas'

export async function createTask(
  userId: string,
  data: CreateTaskInput
): Promise<Task> {
  return prisma.task.create({
    data: {
      title: data.title,
      description: data.description,
      userId,
    },
  })
}

export async function listTasks(
  userId: string,
  limit: number,
  offset: number
): Promise<{ tasks: Task[]; total: number }> {
  const [tasks, total] = await Promise.all([
    prisma.task.findMany({
      where: { userId, isDeleted: false },
      take: limit,
      skip: offset,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.task.count({ where: { userId, isDeleted: false } }),
  ])
  return { tasks, total }
}
