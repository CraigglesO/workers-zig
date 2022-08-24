/**
 * Learn more at https://developers.cloudflare.com/workers/
 */
import { Router } from 'itty-router'
import { zigFetch, getZigWorker } from '../src/index'

const router = Router()
// js route
router.get('/', () => new Response('Hello from JS!'))
// zig route using zig's FetchMap
router.post('/basic', zigFetch<Env>('basic'))
// **KV**
router.get('/kv/string', zigFetch<Env>('kvString'))
router.get('/kv/text', zigFetch<Env>('kvText'))
router.get('/kv/object', zigFetch<Env>('kvObject'))
router.get('/kv/json', zigFetch<Env>('kvJSON'))
router.get('/kv/arraybuffer', zigFetch<Env>('kvArraybuffer'))
router.get('/kv/stream', zigFetch<Env>('kvStream'))
router.get('/kv/bytes', zigFetch<Env>('kvBytes'))
router.get('/kv/delete', zigFetch<Env>('kvDelete'))

// ** ZIG HEAP **
// return the heap to ensure it's cleaned up
export function zigHeap (): Array<any> {
  const worker = getZigWorker()
  return [...worker.heap]
}

export default {
  fetch: router.handle
}
