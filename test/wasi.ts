/**
 * Learn more at https://developers.cloudflare.com/workers/
 */
import { Router } from 'itty-router'
import { zigWasiFetch } from '../src/index'

const router = Router()
// js route
router.get('/', () => new Response('Hello from JS!'))
// **CRYPTO**
router.post('/argon-hash', zigWasiFetch<Env>('argonHash'))
router.post('/argon-verify', zigWasiFetch<Env>('argonVerify'))

export default {
  fetch: router.handle,
}
