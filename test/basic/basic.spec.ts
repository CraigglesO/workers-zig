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
  })
  t.context = { mf }
})

test.afterEach(async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch("http://localhost:8787/heap")
  t.deepEqual(await res.json(), [
    [1, null],
    [2, null], // undefined resolves to null
    [3, true],
    [4, false],
    [5, null], // Infinity resolves to null
    [6, null] // NaN resolves to null
  ])
})

test("basic example", async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch("http://localhost:8787/basic", {
    method: 'POST',
    body: 'Hello from Zig'
  })
  // Check the body was returned
  t.is(res.status, 200)
  t.is(await res.text(), 'Hello from Zig')
})
