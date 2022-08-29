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
    [6, NaN]
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

test('kv: string: putMeta -> getMeta -> return get result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/string-meta')
  // Check the body was returned
  t.is(res.status, 200)
  t.deepEqual(await res.json(), { value: 'value', meta: { name: 'string', input: 1 } })
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

test('kv: text: putMeta -> getMeta -> return get result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/text-meta')
  // Check the body was returned
  t.is(res.status, 200)
  t.deepEqual(await res.json(), { value: 'value2', meta: { name: 'text2', input: 2 } })
})

test('kv: text: put+expirationTtl -> check that data was stored with expire', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/text-expirettl')
  // Check the body was returned
  t.is(res.status, 200)
  // grab the KV and check the data
  const TEST_NAMESPACE = await mf.getKVNamespace("TEST_NAMESPACE")
  const list = await TEST_NAMESPACE.list()
  const firstKey = list.keys[0]
  t.true((firstKey.expiration ?? 0) > (Date.now() / 1000))
  t.is(typeof firstKey.expiration, 'number');
  t.is(firstKey.metadata, undefined)
  t.is(firstKey.name, 'expire')
})

test('kv: text: put+expiration -> check that data was stored with expire', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  const date = Math.floor(Date.now() / 1000) + 100
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/text-expire', {
    method: 'POST',
    body: JSON.stringify({ date })
  })
  // Check the body was returned
  t.is(res.status, 200)
  // grab the KV and check the data
  const TEST_NAMESPACE = await mf.getKVNamespace("TEST_NAMESPACE")
  const list = await TEST_NAMESPACE.list()
  const firstKey = list.keys[0]
  t.true(firstKey.expiration == date)
  t.is(typeof firstKey.expiration, 'number');
  t.is(firstKey.metadata, undefined)
  t.is(firstKey.name, 'expire')
})

test('kv: text: put -> get+cacheTtl: check that cache is storing result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/text-cacheTtl')
  // Check the body was returned
  t.is(res.status, 200)
  t.is(await res.text(), 'value')

  // NOTE: Miniflare doesn't do anything with cache-ttl, but it seems like this works
  // const caches = await mf.getCaches()
  // const defaultCache = caches.default
  // console.log(defaultCache)
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

test('kv: object: putMeta -> getMeta -> return get result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/object-meta')
  // Check the body was returned
  t.is(res.status, 200)
  t.deepEqual(await res.json(), { value: { a: 1, b: 'test' }, meta: { name: 'text3', input: 3 } })
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

test('kv: arraybuffer: putMeta -> getMeta -> return get result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/arraybuffer-meta')
  // Check the body was returned
  t.is(res.status, 200)
  t.deepEqual(await res.json(), { value: { 0: 0, 1: 1, 2: 2, 3: 3 }, meta: { name: 'text4', input: 4 } })
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

test('kv: stream: putMeta -> getMeta -> return get result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/stream-meta')
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

test('kv: bytes: putMeta -> getMeta -> return get result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/bytes-meta')
  // Check the body was returned
  t.is(res.status, 200)
  t.deepEqual(await res.json(), { value: { 0: 0, 1: 1, 2: 2, 3: 3 }, meta: { name: 'text5', input: 5 } })
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
  const data = await res.json()
  // Check the body was returned
  t.is(res.status, 200)
  t.deepEqual(data, {
    listComplete: true,
    cursor: '',
    keys: [
      { name: 'list1' },
      { name: 'list2' },
      { name: 'list3' },
      { name: 'list4' },
      { name: 'list5', metadata: { name: 'test', input: 5 } },
    ]
  })
})
