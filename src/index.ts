import zigWorker from './worker'

import type { ZigWorker, FetchContext } from './worker'

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
    const fetchCtx: FetchContext = { path, req, env, ctx }
    return zigWorker.fetch(fetchCtx)
  }
}

export function zigFunction (name: string, ...args: any[]): Promise<any> {
  return zigWorker.function(name, ...args)
}

export function zigSchedule<Env = {}> (): Event<Env> {
  return async (
    event: ScheduledEvent,
    env: Env,
    executionCtx: ExecutionContext
  ): Promise<void> => {
    return zigWorker.schedule(event, env, executionCtx)
  }
}

/** @internal */
export function getZigWorker (): ZigWorker {
  return zigWorker
}