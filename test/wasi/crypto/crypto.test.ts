import { beforeEach, it, assert } from 'vitest'
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
    scriptPath: "dist/workerWASI.mjs",
  })
})

it<LocalTestContext>("basic example", async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const hashRes = await mf.dispatchFetch("http://localhost:8787/argon-hash", {
    method: 'POST',
    body: JSON.stringify(['testPassword'])
  })
  const hash = await hashRes.text()
  // Check the body was returned
  assert.equal(hashRes.status, 200)
  assert.equal(typeof hash, 'string')
  assert.equal(hash.length, 87)

  const verifyRes = await mf.dispatchFetch("http://localhost:8787/argon-verify", {
    method: 'POST',
    body: JSON.stringify(['testPassword', hash])
  })
  const verifiedString = await verifyRes.text()
  assert.equal(verifyRes.status, 200)
  assert.equal(verifiedString, 'pass')
})
