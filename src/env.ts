import { DEFAULT_HEAP_SIZE } from './heap'
import type WASM from "./wasm"
import type { FetchContext, ScheduleContext } from "./worker"
// All functions accessable to wasm go here.

const CLASSES = [
  Array,
  Object,
  Date,
  Map,
  Set,
  WeakMap,
  WeakSet,
  Int8Array,
  Uint8Array,
  Uint8ClampedArray,
  Int16Array,
  Uint16Array,
  Int32Array,
  Uint32Array,
  BigInt64Array,
  BigUint64Array,
  ArrayBuffer,
  SharedArrayBuffer,
  DataView,
  Request,
  Response,
  Headers,
  FormData,
  File,
  Blob,
  URL,
  URLPattern,
  URLSearchParams,
  ReadableStream,
  WritableStream,
  TransformStream,
  CompressionStream,
  DecompressionStream,
  // @ts-ignore: no idea why vscode is doing this again
  crypto.DigestStream,
  FixedLengthStream,
  WebSocketPair
]

function u32ToU8 (num: number): Uint8Array {
  const resU32 = new Uint32Array([num])
  return new Uint8Array(resU32.buffer)
}

/** HEAP **/
export function jsFree (wasm: WASM, ptr: number): void {
  // leave default values alone
  if (ptr <= DEFAULT_HEAP_SIZE) return
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

export function jsStringThrow (wasm: WASM, stringPtr: number): void {
  throw new Error(wasm.heap.get(stringPtr) as string)
}
/** __STRING__ **/

/** ARRAY */
export function jsArrayPush (wasm: WASM, arrayPtr: number, itemPtr: number) {
  const array = wasm.heap.get(arrayPtr) as Array<any>
  const item = wasm.heap.get(itemPtr)
  array.push(item)
}

export function jsArrayGet (wasm: WASM, arrayPtr: number, pos: number): number {
  const array = wasm.heap.get(arrayPtr) as Array<any>
  return wasm.heap.put(array[pos])
}

export function jsArrayGetNum (wasm: WASM, arrayPtr: number, pos: number): number {
  const array = wasm.heap.get(arrayPtr) as Array<any>
  return array[pos]
}
/** __ARRAY__ */

/** OBJECT */
export function jsObjectHas (wasm: WASM, objPtr: number, keyPtr: number): number {
  const obj = wasm.heap.get(objPtr) as { [key: string]: any }
  const key = wasm.heap.get(keyPtr) as any | undefined
  return wasm.heap.put(obj[key] !== undefined)
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

export function jsObjectGetNum (wasm: WASM, objPtr: number, keyPtr: number): number {
  const obj = wasm.heap.get(objPtr) as { [key: string]: any }
  const key = wasm.heap.get(keyPtr)
  const val = +obj[key]
  if (isNaN(val)) return 0
  return val
}

export function jsStringify (wasm: WASM, objPtr: number): number {
  const obj = wasm.heap.get(objPtr) as { [key: string]: any }
  return wasm.heap.put(JSON.stringify(obj))
}

export function jsParse (wasm: WASM, strPtr: number): number {
  const str = wasm.heap.get(strPtr) as string
  return wasm.heap.put(JSON.parse(str))
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

export function jsCreateClass (wasm: WASM, classPos: number, argsPtr: number): number {
  const Class = CLASSES[classPos]
  const args = wasm.heap.get(argsPtr) as Array<any> | undefined
  // @ts-ignore
  return wasm.heap.put(args !== undefined ? new Class(...args) : new Class())
}

export function jsEqual (wasm: WASM, aPtr: number, bPtr: number): number {
  const a = wasm.heap.get(aPtr)
  const b = wasm.heap.get(bPtr)
  return wasm.heap.put(a === b)
}

export function jsDeepEqual (wasm: WASM, aPtr: number, bPtr: number): number {
  const a = wasm.heap.get(aPtr)
  const b = wasm.heap.get(bPtr)
  try {
    return wasm.heap.put(JSON.stringify(a) == JSON.stringify(b))
  } catch (_) { return wasm.heap.put(false) }
}

export function jsInstanceOf (wasm: WASM, classPos: number, classPrt: number): number {
  const Class = CLASSES[classPos]
  const classPtr = wasm.heap.get(classPrt)
  return classPtr instanceof Class ? wasm.heap.put(true) : wasm.heap.put(false)
}

export function jsResolve (wasm: WASM, ctxPtr: number, resPtr: number): void {
  const ctx = wasm.heap.get(ctxPtr) as FetchContext | ScheduleContext
  const res = wasm.heap.get(resPtr) as Response // undefined if ScheduleContext
  ctx.resolve?.(res)
}

/** __FUNCTION__ */

/** UTIL **/
export function jsLog (wasm: WASM, stringPtr: number): void {
  console.log(wasm.heap.get(stringPtr) as string)
}

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

export function jsToBuffer (wasm: WASM, ptr: number, len: number): number {
  const data = wasm.get(ptr, len)
  return wasm.heap.put(data.buffer)
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
  keyPtr: number,
  resPtr: number
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
  urlPtr: number,
  initPtr: number,
  resPtr: number,
): Promise<void> {
  const url = wasm.heap.get(urlPtr) as string | Request
  const init = wasm.heap.get(initPtr) as RequestInit | Request | undefined
  const res = wasm.heap.put(await fetch(url, init))

  wasm.put(u32ToU8(res), resPtr)
  wasm.resume(frame)
}
/** __FETCH__ **/

/** CRYPTO **/
export function jsRandomUUID (wasm: WASM): number {
  const uuid = crypto.randomUUID()
  return wasm.putString(uuid)
}

export function jsGetRandomValues (wasm: WASM, bufPtr: number): void {
  const buffer = wasm.heap.get(bufPtr) as ArrayBufferView
  crypto.getRandomValues(buffer)
}

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
