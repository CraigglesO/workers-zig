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

it<LocalTestContext>('kv: string: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/string')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.equal(await res.text(), 'value')
})

it<LocalTestContext>('kv: string: putMeta -> getMeta -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/string-meta')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(await res.json(), { value: 'value', meta: { name: 'string', input: 1 } })
})

it<LocalTestContext>('kv: text: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/text')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.equal(await res.text(), 'value2')
})

it<LocalTestContext>('kv: text: putMeta -> getMeta -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/text-meta')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(await res.json(), { value: 'value2', meta: { name: 'text2', input: 2 } })
})

it<LocalTestContext>('kv: text: put+expirationTtl -> check that data was stored with expire', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/text-expirettl')
  // Check the body was returned
  assert.equal(res.status, 200)
  // grab the KV and check the data
  const TEST_NAMESPACE = await mf.getKVNamespace("TEST_NAMESPACE")
  const list = await TEST_NAMESPACE.list()
  const firstKey = list.keys[0]
  assert.isTrue((firstKey.expiration ?? 0) > (Date.now() / 1000))
  assert.equal(typeof firstKey.expiration, 'number');
  assert.equal(firstKey.metadata, undefined)
  assert.equal(firstKey.name, 'expire')
})

it<LocalTestContext>('kv: text: put+expiration -> check that data was stored with expire', async ({ mf }) => {
  const date = Math.floor(Date.now() / 1000) + 100
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/text-expire', {
    method: 'POST',
    body: JSON.stringify({ date })
  })
  // Check the body was returned
  assert.equal(res.status, 200)
  // grab the KV and check the data
  const TEST_NAMESPACE = await mf.getKVNamespace("TEST_NAMESPACE")
  const list = await TEST_NAMESPACE.list()
  const firstKey = list.keys[0]
  assert.isTrue(firstKey.expiration == date)
  assert.equal(typeof firstKey.expiration, 'number');
  assert.equal(firstKey.metadata, undefined)
  assert.equal(firstKey.name, 'expire')
})

it<LocalTestContext>('kv: text: put -> get+cacheTtl: check that cache is storing result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/text-cacheTtl')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.equal(await res.text(), 'value')

  // NOTE: Miniflare doesn't do anything with cache-ttl, but it seems like this works
  // const caches = await mf.getCaches()
  // const defaultCache = caches.default
  // console.log(defaultCache)
})

it<LocalTestContext>('kv: object: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/object')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(await res.json(), { a: 1, b: 'test' })
})

it<LocalTestContext>('kv: object: putMeta -> getMeta -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/object-meta')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(await res.json(), { value: { a: 1, b: 'test' }, meta: { name: 'text3', input: 3 } })
})

it<LocalTestContext>('kv: json: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/json')
  // console.log(await res.text())
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(await res.json(), { a: 1, b: 'test' })
})

it<LocalTestContext>('kv: arraybuffer: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/arraybuffer')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(new Uint8Array(await res.arrayBuffer()), new Uint8Array([0, 1, 2, 3]))
})

it<LocalTestContext>('kv: arraybuffer: putMeta -> getMeta -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/arraybuffer-meta')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(await res.json(), { value: { 0: 0, 1: 1, 2: 2, 3: 3 }, meta: { name: 'text4', input: 4 } })
})

it<LocalTestContext>('kv: stream: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/stream')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(new Uint8Array(await res.arrayBuffer()), new Uint8Array([0, 1, 2, 3]))
})

it<LocalTestContext>('kv: stream: putMeta -> getMeta -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/stream-meta')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(new Uint8Array(await res.arrayBuffer()), new Uint8Array([0, 1, 2, 3]))
})

it<LocalTestContext>('kv: bytes: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/bytes')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(new Uint8Array(await res.arrayBuffer()), new Uint8Array([0, 1, 2, 3]))
})

it<LocalTestContext>('kv: bytes: putMeta -> getMeta -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/bytes-meta')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(await res.json(), { value: { 0: 0, 1: 1, 2: 2, 3: 3 }, meta: { name: 'text5', input: 5 } })
})

it<LocalTestContext>('kv: delete: put -> delete -> get -> return result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/delete')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.equal(await res.text(), 'deleted')
})

it<LocalTestContext>('kv: list: put many -> list -> return list details', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/kv/list')
  const data = await res.json()
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(data, {
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
