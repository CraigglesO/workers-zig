import { beforeEach, afterEach, it, assert } from 'vitest'
import { Miniflare } from 'miniflare'

interface LocalTestContext {
  mf: Miniflare
}

beforeEach<LocalTestContext>(async (ctx) => {
  // Create a new Miniflare environment for each test
  ctx.mf = new Miniflare({
    // Autoload configuration from `.env`, `package.json` and `wrangler.toml`
    envPath: true,
    packagePath: true,
    wranglerConfigPath: true,
    // We don't want to rebuild our worker for each test, we're already doing
    // it once before we run all tests in package.json, so disable it here.
    // This will override the option in wrangler.toml.
    buildCommand: undefined,
    modules: true,
    kvNamespaces: ['TEST_NAMESPACE'],
    scriptPath: "dist/worker.mjs",
  })
})

afterEach<LocalTestContext>(async ({ mf }) => {
  // grab exports
  const { zigHeap } = await mf.getModuleExports()
  // Check that the heap is empty
  assert.deepEqual(zigHeap(), [
    [1, null],
    [2, undefined],
    [3, true],
    [4, false],
    [5, Infinity],
    [6, NaN] // NaN resolves to null
  ])
})

it<LocalTestContext>('cache: text: put -> match -> return match result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/cache/text')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.equal(await res.text(), 'cached response')
})

it<LocalTestContext>('cache: string: put -> match -> return match result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/cache/string')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.equal(await res.text(), 'cached response')
})

it<LocalTestContext>('cache: unique: put -> match -> return match result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/cache/unique')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.equal(await res.text(), 'cached response')
  // check cache is comming from updated cache source
  const caches = await mf.getCaches()
  const cache = await caches.open('newcache')
  const checkCache = await cache.match('http://localhost/cacheTest')
  assert.equal(await checkCache?.text(), 'cached response')
})

it<LocalTestContext>('cache: delete: put -> delete -> match -> return match result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/cache/delete')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.equal(await res.text(), 'deleted cached response')
})

it<LocalTestContext>('cache: text: ignoreMethod: put -> match -> return match result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/cache/ignore/text')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.equal(await res.text(), 'cached response')
})

it<LocalTestContext>('cache: delete: ignoreMethod: put -> delete -> match -> return match result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/cache/ignore/delete')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.equal(await res.text(), 'deleted cached response')
})
