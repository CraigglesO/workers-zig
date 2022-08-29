/**
 * Learn more at https://developers.cloudflare.com/workers/
 */
import { Router } from 'itty-router'
import { zigFetch, zigSchedule, getZigWorker } from '../src/index'

const router = Router()
// js route
router.get('/', () => new Response('Hello from JS!'))
// zig route using zig's FetchMap
router.post('/basic', zigFetch<Env>('basic'))
// **FETCH**
router.get('/fetch', zigFetch<Env>('fetch'))
// **CACHE**
router.get('/cache/text', zigFetch<Env>('cacheText'))
router.get('/cache/string', zigFetch<Env>('cacheString'))
router.get('/cache/unique', zigFetch<Env>('cacheUnique'))
router.get('/cache/delete', zigFetch<Env>('cacheDelete'))
router.get('/cache/ignore/text', zigFetch<Env>('cacheIgnoreText'))
router.get('/cache/ignore/delete', zigFetch<Env>('cacheIgnoreDelete'))
// **KV**
router.get('/kv/string', zigFetch<Env>('kvString'))
router.get('/kv/string-meta', zigFetch<Env>('kvStringMeta'))
router.get('/kv/text', zigFetch<Env>('kvText'))
router.get('/kv/text-meta', zigFetch<Env>('kvTextMeta'))
router.get('/kv/text-expirettl', zigFetch<Env>('kvTextExpireTtl'))
router.post('/kv/text-expire', zigFetch<Env>('kvTextExpire'))
router.get('/kv/text-cacheTtl', zigFetch<Env>('kvTextCacheTtl'))
router.get('/kv/object', zigFetch<Env>('kvObject'))
router.get('/kv/object-meta', zigFetch<Env>('kvObjectMeta'))
router.get('/kv/json', zigFetch<Env>('kvJSON'))
router.get('/kv/arraybuffer', zigFetch<Env>('kvArraybuffer'))
router.get('/kv/arraybuffer-meta', zigFetch<Env>('kvArraybufferMeta'))
router.get('/kv/stream', zigFetch<Env>('kvStream'))
router.get('/kv/stream-meta', zigFetch<Env>('kvStreamMeta'))
router.get('/kv/bytes', zigFetch<Env>('kvBytes'))
router.get('/kv/bytes-meta', zigFetch<Env>('kvBytesMeta'))
router.get('/kv/delete', zigFetch<Env>('kvDelete'))
router.get('/kv/list', zigFetch<Env>('kvList'))
// **R2**
router.get('/r2/stream', zigFetch<Env>('r2Stream'))
router.get('/r2/text', zigFetch<Env>('r2Text'))
router.get('/r2/string', zigFetch<Env>('r2String'))

// ** ZIG HEAP **
// return the heap to ensure it's cleaned up
export function zigHeap (): Array<any> {
  const worker = getZigWorker()
  return [...worker.heap]
}

export default {
  fetch: router.handle,
  scheduled: zigSchedule
}
