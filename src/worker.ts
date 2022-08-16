import WASM from './wasm'

export interface FetchContext {
  req: Request,
  env: any,
  ctx: ExecutionContext,
  resolve?: (res: Response) => void
}

export interface ScheduleContext {
  event: ScheduledEvent,
  env: any,
  ctx: ExecutionContext,
  resolve?: () => void
}

export type ZigFunction = (id: number) => number

export type ZigUserFunction = (...args: any[]) => any

class ZigWorker extends WASM {
  async fetch (
    name: string, // name of the function
    req: Request,
    env: any,
    ctx: ExecutionContext
  ): Promise<Response> {
    // pull in the heap
    const { heap } = this
    // ensure wasm has been build
    await this._buildWASM()

    // build a context
    const context: FetchContext = { req, env, ctx }
    const id = heap.put(context)

    // grab the zig function and build a promise
    const fetchFunc = this.instance.exports[name] as ZigFunction
    return new Promise<Response>(resolve => {
      context.resolve = resolve
      fetchFunc(id)
    })
  }

  async function (
    name: string, // name of the function
    ...args: any[] // arguments to pass to the function
  ): Promise<any> {
    // ensure wasm has been build
    await this._buildWASM()

    // grab the zig function and build a promise
    const fetchFunc = this.instance.exports[name] as ZigUserFunction
    return fetchFunc(...args)
  }

  async asyncFunction (
    name: string, // name of the function
    ...args: any[] // arguments to pass to the function
  ): Promise<any> {
    // ensure wasm has been build
    await this._buildWASM()

    // grab the zig function and build a promise
    const fetchFunc = this.instance.exports[name] as ZigUserFunction
    return new Promise<Response>(resolve => {
      fetchFunc(resolve, ...args)
    })
  }

  async schedule (
    event: ScheduledEvent,
    env: any,
    ctx: ExecutionContext
  ): Promise<void> {
    const { heap } = this
    // ensure wasm has been build
    await this._buildWASM()

    // build a scheduleContext
    const context: ScheduleContext = { event, env, ctx }
    const id = heap.put(context)

    // grab the zig function
    const zigSchedule = this.instance.exports.schedule as ZigFunction

    return new Promise<void>(resolve => {
      context.resolve = resolve
      zigSchedule(id)
    })
  }
}

export default new ZigWorker()
