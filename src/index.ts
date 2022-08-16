import zigWorker from './worker'

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

export function zigFetch<Env = {}> (name: string): Route<Env> {
  return async (
    request: Request,
    env: Env,
    executionCtx: ExecutionContext
  ): Promise<Response> => {
    return zigWorker.fetch(name, request, env, executionCtx)
  }
}

export function zigFunction (name: string, ...args: any[]): Promise<any> {
  return zigWorker.function(name, ...args)
}

export function zigAsyncFunction (name: string, ...args: any[]): Promise<any> {
  return zigWorker.asyncFunction(name, ...args)
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
