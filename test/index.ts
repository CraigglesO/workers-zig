/**
 * Learn more at https://developers.cloudflare.com/workers/
 */
import { Router } from 'itty-router'
import { zigFetch } from '../src/index'

export interface Env {
  BUCKET: R2Bucket
}

const router = Router()
router.get('/', () => new Response('Hello from JS!'))
router.post('/basic', zigFetch<Env>('basicFetch'))

// default methodology
export default {
  fetch: router.handle
}

// if using zig fetch directly
// export default {
//   fetch: zigFetch<Env>('basicFetch')
// }
