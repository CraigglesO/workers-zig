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

it<LocalTestContext>("basic example", async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch("http://localhost:8787/basic", {
    method: 'POST',
    body: 'Hello from Zig'
  })
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.equal(await res.text(), 'Hello from Zig')
})
