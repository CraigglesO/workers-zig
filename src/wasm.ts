import Heap from './heap'
import * as envFunctions from './env'

export const textDecoder = new TextDecoder()
export const textEncoder = new TextEncoder()

type WasmAlloc = (size: number) => number
type WasmAllocSentinel = (size: number) => number

export default class WASM {
  heap: Heap = new Heap()
  routerPtr?: number
  idGen: number = 0
  instance!: WebAssembly.Instance
  wasmMemory?: Uint8Array

  #buildFunctions (): { [key: string]: Function } {
    const builtFunctions: { [key: string]: Function } = {}
    for (const [key, value] of Object.entries(envFunctions)) {
      // @ts-ignore
      builtFunctions[key] = (...args: any[]): any => value(this, ...args)
    }

    return builtFunctions
  }

  async _buildWASM () {
    if (this.instance !== undefined) return
    // @ts-ignore
    this.instance = new WebAssembly.Instance(__WORKER_ZIG_WASM, {
      env: {
        memoryBase: 0,
        tableBase: 0,
        memory: new WebAssembly.Memory({ initial: 512 }),
        ...this.#buildFunctions()
      }
    })

    // If there is a main function, run it
    const main = this.instance.exports.main as Function | undefined
    if (main !== undefined) this.routerPtr = main()
  }

  /* HELPERS */
  alloc (size: number): number {
    const alloc = this.instance.exports.alloc as WasmAlloc
    return alloc(size)
  }

  allocSentinel (size: number): number {
    const allocSentinel = this.instance.exports.allocSentinel as WasmAllocSentinel
    return allocSentinel(size)
  }

  resume (frame: number): void {
    const resume = this.instance.exports.wasmResume as Function
    resume(frame)
  }

  get (ptr: number, len: number): Uint8Array {
    const view = this.getMemory()
    const slice = view.subarray(ptr, ptr + len)
    const copy = new Uint8Array(slice.byteLength)
    copy.set(slice)
    return copy
  }

  put (buf: Uint8Array, ptr?: number): number {
    const len = buf.byteLength
    if (ptr === undefined) ptr = this.alloc(len)

    const view = this.getMemory()
    view.subarray(ptr, ptr + len).set(buf)

    return ptr
  }

  getString (ptr: number, len: number): string {
    return textDecoder.decode(this.get(ptr, len))
  }

  putString(str: string): number {
    const buf = textEncoder.encode(str)
    const len = buf.byteLength
    const ptr = this.allocSentinel(len)

    const view = this.getMemory()
    view.subarray(ptr, ptr + len).set(buf)

    return ptr
  }

  getMemory (): Uint8Array {
    const memory = this.instance.exports.memory as WebAssembly.Memory
    if (
      this.wasmMemory === undefined ||
      this.wasmMemory !== memory.buffer
    ) {
      this.wasmMemory = new Uint8Array(memory.buffer)
    }
    return this.wasmMemory
  }
}
