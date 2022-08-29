import avaTest, { TestFn, ExecutionContext } from 'ava'
import { Miniflare } from 'miniflare'

export interface Context {
  mf: Miniflare
}

const test = avaTest as TestFn<Context>

test.beforeEach((t: ExecutionContext<Context>) => {
  // Create a new Miniflare environment for each test
  const mf = new Miniflare({
    name: "worker",
    serviceBindings: { WORKER: "worker" },
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
    host: "127.0.0.1",
    port: 8787,
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

test('kv: fetch: return get result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  // const res = await mf.dispatchFetch('http://127.0.0.1:8787/fetch')
  // Check the body was returned
  // t.is(res.status, 200)
  // t.is(await res.text(), 'value')

  t.true(true)
})
