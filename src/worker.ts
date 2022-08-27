import WASM from './wasm'

export interface FetchContext {
  path: string,
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

export class ZigWorker extends WASM {
  async fetch (context: FetchContext): Promise<Response> {
    // pull in the heap
    const { heap } = this
    // ensure wasm has been build
    await this._buildWASM()

    // grab the zig function and build a promise
    const fetchEvent = this.instance.exports.fetchEvent as ZigFunction
    return new Promise<Response>(resolve => {
      context.resolve = resolve
      fetchEvent(heap.put(context))
    })
  }

  async function (
    name: string, // name of the function
    args?: { [key: string]: any } // arguments to pass to the function
  ): Promise<any> {
    // pull in the heap
    const { heap } = this
    // ensure wasm has been build
    await this._buildWASM()

    // store the args
    const argsID = heap.put(args)

    // grab the zig function and build a promise
    const fetchFunc = this.instance.exports[name] as ZigUserFunction
    return fetchFunc(argsID)
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
