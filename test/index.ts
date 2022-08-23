/**
 * Learn more at https://developers.cloudflare.com/workers/
 */
import { Router } from 'itty-router'
import { zigFetch, getZigWorker } from '../src/index'

const router = Router()
// proof the router works
router.get('/', () => new Response('Hello from JS!'))
// return the heap to ensure it's cleaned up
router.get('/heap', () => {
  const worker = getZigWorker()
  const headers = new Headers()
  headers.set('content-type', 'application/json')
  return new Response(JSON.stringify([...worker.heap]), { headers })
})
// basic example
router.post('/basic', zigFetch<Env>('basicFetch'))
// **KV**
router.get('/kv/string', zigFetch<Env>('kvString'))
router.get('/kv/text', zigFetch<Env>('kvText'))
router.get('/kv/object', zigFetch<Env>('kvObject'))
// router.get('/kv/json', zigFetch<Env>('kvJSON'))
router.get('/kv/arraybuffer', zigFetch<Env>('kvArraybuffer'))
router.get('/kv/bytes', zigFetch<Env>('kvBytes'))
router.get('/kv/delete', zigFetch<Env>('kvDelete'))

export default {
  fetch: router.handle
}
