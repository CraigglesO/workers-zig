import type WASM from "./wasm"
import type { FetchContext, ScheduleContext } from "./worker"
// All functions accessable to wasm go here.

const CLASSES = [
  Uint8Array,
  Request,
  Response,
  Headers,
  FormData,
  File,
  Blob,
  URL,
  URLSearchParams,
  ReadableStream,
  WritableStream,
  TransformStream,
  WebSocketPair
]

function u32ToU8 (num: number): Uint8Array {
  const resU32 = new Uint32Array([num])
  return new Uint8Array(resU32.buffer)
}

/** HEAP **/
export function jsFree (wasm: WASM, ptr: number): void {
  // leave default values alone
  if (ptr <= 4) return
  wasm.heap.delete(ptr)
}
/** __HEAP__ **/

/** STRING **/
// shows where the string is stored in zig's heap so js can store it locally
// return the location of the string in the heap
export function jsStringSet (wasm: WASM, ptr: number, len: number): number {
  const string = wasm.getString(ptr, len)
  return wasm.heap.put(string)
}

// pushes the string onto zig's heap and returns the pointer to the string
export function jsStringGet (wasm: WASM, stringPtr: number): number {
  const string = wasm.heap.get(stringPtr) as string
  return wasm.putString(string)
}

export function jsStringLog (wasm: WASM, stringPtr: number): void {
  console.log(wasm.heap.get(stringPtr) as string)
}

export function jsStringThrow (wasm: WASM, stringPtr: number): void {
  throw new Error(wasm.heap.get(stringPtr) as string)
}
/** __STRING__ **/

/** ARRAY */
export function jsArrayNew (wasm: WASM): number {
  return wasm.heap.put(new Array())
}

export function jsArrayPush (wasm: WASM, arrayPtr: number, itemPtr: number) {
  const array = wasm.heap.get(arrayPtr) as Array<any>
  const item = wasm.heap.get(itemPtr)
  array.push(item)
}
/** __ARRAY__ */

/** OBJECT */
export function jsObjectNew (wasm: WASM): number {
  return wasm.heap.put(new Object())
}

export function jsObjectSet (wasm: WASM, objPtr: number, keyPtr: number, valuePtr: number) {
  const obj = wasm.heap.get(objPtr) as { [key: string]: any }
  const key = wasm.heap.get(keyPtr)
  const value = wasm.heap.get(valuePtr)
  obj[key] = value
}

export function jsObjectSetNum (wasm: WASM, objPtr: number, keyPtr: number, value: number) {
  const obj = wasm.heap.get(objPtr) as { [key: string]: any }
  const key = wasm.heap.get(keyPtr)
  obj[key] = value
}

export function jsObjectGet (wasm: WASM, objPtr: number, keyPtr: number): number {
  const obj = wasm.heap.get(objPtr) as { [key: string]: any }
  const key = wasm.heap.get(keyPtr)
  return wasm.heap.put(typeof obj[key] === 'function' ? obj[key].bind(obj) : obj[key])
}

export function jsStringify (wasm: WASM, objPtr: number): number {
  const obj = wasm.heap.get(objPtr) as { [key: string]: any }
  return wasm.heap.put(JSON.stringify(obj))
}
/** __OBJECT__ */

/** FUNCTION */
export function jsFnCall (wasm: WASM, funcPtr: number, argsPtr: number) {
  const func = wasm.heap.get(funcPtr) as Function
  const args = wasm.heap.get(argsPtr) as Array<any> | undefined
  const res = args === undefined ? func() : Array.isArray(args) ? func(...args) : func(args)
  return wasm.heap.put(res)
}

export async function jsAsyncFnCall (
  wasm: WASM,
  frame: number,
  funcPtr: number,
  argsPtr: number,
  resPtr: number
) {
  const func = wasm.heap.get(funcPtr) as Function
  const args = wasm.heap.get(argsPtr) as Array<any> | undefined
  const prom = args === undefined ? func() : Array.isArray(args) ? func(...args) : func(args)
  const res = wasm.heap.put(await prom)
  wasm.put(u32ToU8(res), resPtr)
  wasm.resume(frame)
}

export function jsCreateClass (wasm: WASM, className: number, argsPtr: number): number {
  const ClassFunc = CLASSES[className]
  const args = wasm.heap.get(argsPtr) as Array<any> | undefined
  // @ts-ignore
  return wasm.heap.put(args !== undefined ? new ClassFunc(...args) : new ClassFunc())
}

export function jsResolve (wasm: WASM, ctxPtr: number, resPtr: number): void {
  const ctx = wasm.heap.get(ctxPtr) as FetchContext | ScheduleContext
  const res = wasm.heap.get(resPtr) as Response // undefined if ScheduleContext
  ctx.resolve?.(res)
  logHeap(wasm)
}

async function logHeap(wasm: WASM): Promise<void> {
  return new Promise(resolve => {
    setTimeout(() => {
      console.log(wasm.heap)
      resolve()
    }, 1_000)
  })
}
/** __FUNCTION__ */

/** UTIL **/
export function jsSize (wasm: WASM, ptr: number): number {
  const data = wasm.heap.get(ptr) as ArrayBuffer | Uint8Array | Array<any>
  return 'byteLength' in data ? data.byteLength : data.length
}

export function jsToBytes (wasm: WASM, ptr: number): number {
  const data = wasm.heap.get(ptr) as ArrayBuffer | Uint8Array
  let bytes: Uint8Array
  if (data instanceof ArrayBuffer) {
    bytes = new Uint8Array(data)
  } else if (data instanceof Uint8Array) {
    bytes = data
  } else {
    throw new Error('jsToBytes: data is not an array buffer or uint8 array')
  }
  return wasm.put(bytes)
}
/** __UTIL__ **/

// **** API ****

/** CONTEXT **/
export function jsWaitUntil (wasm: WASM, ctxPtr: number): number {
  const ctx = wasm.heap.get(ctxPtr) as ExecutionContext
  // create a promise and capture the resolver
  const resolver: { resolve: (value: any) => void } = { resolve: () => {} }
  ctx.waitUntil(new Promise(resolve => {
    resolver.resolve = resolve
  }))
  return wasm.heap.put(resolver.resolve)
}
/** __CONTEXT__ **/

/** CACHE **/
export async function jsCacheGet (
  wasm: WASM,
  frame: number,
  resPtr: number,
  keyPtr: number
): Promise<void> {
  const key = wasm.heap.get(keyPtr) as string | undefined
  // @ts-ignore: caches.default isn't working in my VS Code currently.
  const res = wasm.heap.put(key !== undefined ? await caches.open(key) : caches.default)

  wasm.put(u32ToU8(res), resPtr)
  wasm.resume(frame)
}
/** __CACHE__ **/

/** FETCH **/
export async function jsFetch (
  wasm: WASM,
  frame: number,
  resPtr: number,
  urlPtr: number,
  initPtr: number
): Promise<void> {
  const url = wasm.heap.get(urlPtr) as string | Request
  const init = wasm.heap.get(initPtr) as RequestInit | Request | undefined
  const res = wasm.heap.put(await fetch(url, init))

  wasm.put(u32ToU8(res), resPtr)
  wasm.resume(frame)
}
/** __FETCH__ **/

/** CRYPTO **/
export async function jsCrypto (
  wasm: WASM,
  frame: number,
  resPtr: number,
  namePtr: number,
  argsPtr: number
): Promise<void> {
  const name = wasm.heap.get(namePtr) as string
  const args = wasm.heap.get(argsPtr) as Array<any> | undefined
  // @ts-ignore
  const res = wasm.heap.put(await crypto.subtle[name](...args))

  wasm.put(u32ToU8(res), resPtr)
  wasm.resume(frame)
}
/** __CRYPTO__ **/
