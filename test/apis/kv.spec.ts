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
    [6, NaN] // NaN resolves to null
  ])
})

test('kv: string: put -> get -> return get result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/string')
  // Check the body was returned
  t.is(res.status, 200)
  t.is(await res.text(), 'value')
})

test('kv: text: put -> get -> return get result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/text')
  // Check the body was returned
  t.is(res.status, 200)
  t.is(await res.text(), 'value2')
})

test('kv: object: put -> get -> return get result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/object')
  // Check the body was returned
  t.is(res.status, 200)
  t.deepEqual(await res.json(), { a: 1, b: 'test' })
})

test('kv: json: put -> get -> return get result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/json')
  // console.log(await res.text())
  // Check the body was returned
  t.is(res.status, 200)
  t.deepEqual(await res.json(), { a: 1, b: 'test' })
})

test('kv: arraybuffer: put -> get -> return get result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/arraybuffer')
  // Check the body was returned
  t.is(res.status, 200)
  t.deepEqual(new Uint8Array(await res.arrayBuffer()), new Uint8Array([0, 1, 2, 3]))
})

test('kv: stream: put -> get -> return get result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/stream')
  // Check the body was returned
  t.is(res.status, 200)
  t.deepEqual(new Uint8Array(await res.arrayBuffer()), new Uint8Array([0, 1, 2, 3]))
})

test('kv: bytes: put -> get -> return get result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/bytes')
  // Check the body was returned
  t.is(res.status, 200)
  t.deepEqual(new Uint8Array(await res.arrayBuffer()), new Uint8Array([0, 1, 2, 3]))
})

test('kv: delete: put -> delete -> get -> return result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/delete')
  // Check the body was returned
  t.is(res.status, 200)
  t.is(await res.text(), 'deleted')
})

test('kv: list: put many -> list -> return list details', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/list')
  // Check the body was returned
  t.is(res.status, 200)
  t.deepEqual(await res.json(), {
    listComplete: true,
    cursor: '',
  })
})
