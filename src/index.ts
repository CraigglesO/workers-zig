import { wasiFetch } from './wasi'
import ZigWorker from './worker'

import type { FetchContext } from './worker'

let zigWorker: ZigWorker

export type Route<Env> = (
  request: Request,
  env: Env,
  ctx: ExecutionContext
) => Promise<Response>

export type Event<Env> = (
  event: ScheduledEvent,
  env: Env,
  ctx: ExecutionContext
) => Promise<void>

// Uses zig's FetchMap. Future: FetchMap will also include a trie-router.
export function zigFetch<Env = {}> (path: string): Route<Env> {
  return async (
    req: Request,
    env: Env,
    ctx: ExecutionContext
  ): Promise<Response> => {
    if (zigWorker === undefined) zigWorker = new ZigWorker()
    const fetchCtx: FetchContext = { path, req, env, ctx }
    return zigWorker.fetch(fetchCtx)
  }
}

export function zigWasiFetch<Env = {}> (path: string): Route<Env> {
  return async (
    req: Request,
    env: Env,
    ctx: ExecutionContext
  ): Promise<Response> => {
    const fetchCtx: FetchContext = { path, req, env, ctx }
    return wasiFetch(fetchCtx)
  }
}

export function zigFunction (name: string, ...args: any[]): Promise<any> {
  if (zigWorker === undefined) zigWorker = new ZigWorker()
  return zigWorker.function(name, ...args)
}

export async function zigSchedule<Env = {}> (
  event: ScheduledEvent,
  env: Env,
  executionCtx: ExecutionContext
): Promise<void> {
  if (zigWorker === undefined) zigWorker = new ZigWorker()
  return zigWorker.schedule(event, env, executionCtx)
}

/** @internal */
export function getZigWorker (): ZigWorker {
  if (zigWorker === undefined) zigWorker = new ZigWorker()
  return zigWorker
}