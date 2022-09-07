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
    scriptPath: "dist/workerWASI.mjs",
  })
  t.context = { mf }
})

test("basic example", async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const hashRes = await mf.dispatchFetch("http://localhost:8787/argon-hash", {
    method: 'POST',
    body: JSON.stringify(['testPassword'])
  })
  const hash = await hashRes.text()
  // Check the body was returned
  t.is(hashRes.status, 200)
  t.is(typeof hash, 'string')
  t.is(hash.length, 87)

  const verifyRes = await mf.dispatchFetch("http://localhost:8787/argon-verify", {
    method: 'POST',
    body: JSON.stringify(['testPassword', hash])
  })
  const verifiedString = await verifyRes.text()
  t.is(verifyRes.status, 200)
  t.is(verifiedString, 'pass')
})
