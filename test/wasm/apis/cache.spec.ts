import avaTest, { TestFn, ExecutionContext } from 'ava'
import { Miniflare } from 'miniflare'

export interface Context {
  mf: Miniflare
}

const test = avaTest as TestFn<Context>

test.beforeEach((t: ExecutionContext<Context>) => {
  // Create a new Miniflare environment for each test
  const mf = new Miniflare({
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
  t.context = { mf }
})

test.afterEach(async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // grab exports
  const { zigHeap } = await mf.getModuleExports()
  // Check that the heap is empty
  t.deepEqual(zigHeap(), [
    [1, null],
    [2, undefined],
    [3, true],
    [4, false],
    [5, Infinity],
    [6, NaN]
  ])
})

test('cache: text: put -> match -> return match result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/cache/text')
  // Check the body was returned
  t.is(res.status, 200)
  t.is(await res.text(), 'cached response')
})

test('cache: string: put -> match -> return match result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/cache/string')
  // Check the body was returned
  t.is(res.status, 200)
  t.is(await res.text(), 'cached response')
})

test('cache: unique: put -> match -> return match result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/cache/unique')
  // Check the body was returned
  t.is(res.status, 200)
  t.is(await res.text(), 'cached response')
  // check cache is comming from updated cache source
  const caches = await mf.getCaches()
  const cache = await caches.open('newcache')
  const checkCache = await cache.match('http://localhost/cacheTest')
  t.is(await checkCache?.text(), 'cached response')
})

test('cache: delete: put -> delete -> match -> return match result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/cache/delete')
  // Check the body was returned
  t.is(res.status, 200)
  t.is(await res.text(), 'deleted cached response')
})

test('cache: text: ignoreMethod: put -> match -> return match result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/cache/ignore/text')
  // Check the body was returned
  t.is(res.status, 200)
  t.is(await res.text(), 'cached response')
})

test('cache: delete: ignoreMethod: put -> delete -> match -> return match result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/cache/ignore/delete')
  // Check the body was returned
  t.is(res.status, 200)
  t.is(await res.text(), 'deleted cached response')
})
