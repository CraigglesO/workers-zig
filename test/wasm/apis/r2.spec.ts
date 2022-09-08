import { beforeEach, afterEach, it, assert } from 'vitest'
import { Miniflare } from 'miniflare'

interface LocalTestContext {
  mf: Miniflare
}

beforeEach<LocalTestContext>(async (ctx) => {
  // Create a new Miniflare environment for each it<LocalTestContext>
  ctx.mf = new Miniflare({
    // Autoload configuration from `.env`, `package.json` and `wrangler.toml`
    envPath: true,
    packagePath: true,
    wranglerConfigPath: true,
    // We don't want to rebuild our worker for each it<LocalTestContext>, we're already doing
    // it once before we run all it<LocalTestContext>s in package.json, so disable it here.
    // This will override the option in wrangler.toml.
    buildCommand: undefined,
    modules: true,
    r2Buckets: ['TEST_BUCKET'],
    scriptPath: 'dist/worker.mjs',
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

it<LocalTestContext>('r2: stream: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/r2/stream')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.equal(await res.text(), 'value')
})

it<LocalTestContext>('r2: text: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/r2/text')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.equal(await res.text(), 'value')
})

it<LocalTestContext>('r2: string: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/r2/string')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.equal(await res.text(), 'value')
})

it<LocalTestContext>('r2: arrayBuffer: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/r2/array-buffer')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(new Uint8Array(await res.arrayBuffer()), new Uint8Array([0, 1, 2, 3]))
})

it<LocalTestContext>('r2: bytes: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/r2/bytes')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(new Uint8Array(await res.arrayBuffer()), new Uint8Array([0, 1, 2, 3]))
})

it<LocalTestContext>('r2: object: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/r2/object')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(await res.json(), { a: 1, b: 'test' })
})

it<LocalTestContext>('r2: json: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/r2/json')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(await res.json(), { a: 1, b: 'test' })
})

it<LocalTestContext>('r2: head: put -> head -> return head result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/r2/head')
  const obj: R2Object = await res.json()
  const copy = { ...obj }
  
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.isNotNull(copy.uploaded)
  const date = new Date()
  copy.uploaded = date
  assert.isNotNull(copy.version)
  copy.version = ''
  assert.deepEqual(copy, {
    customMetadata: {},
    etag: '034fd23a497ff794f10bd7a2bf6abff9',
    httpEtag: '"034fd23a497ff794f10bd7a2bf6abff9"',
    httpMetadata: {},
    key: 'key',
    size: 18,
    uploaded: date,
    version: ''
  })
})

it<LocalTestContext>('r2: delete: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/r2/delete')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.equal(await res.text(), 'value deleted')
})

it<LocalTestContext>('r2: list: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/r2/list')
  const obj: any = await res.json()
  const clone = { ...obj }
  clone.objects = clone.objects.map((obj: any) => {
    delete obj.uploaded
    delete obj.version
    return obj
  })
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(clone, {
    cursor: '',
    delimitedPrefixes: [],
    truncated: false,
    objects: [
      {
        customMetadata: {},
        etag: '5b92cd4d313bb810c60cd65c0e7bfe53',
        httpEtag: '"5b92cd4d313bb810c60cd65c0e7bfe53"',
        httpMetadata: {},
        key: 'key0',
        size: 6,
      },
      {
        customMetadata: {},
        etag: '9946687e5fa0dab5993ededddb398d2e',
        httpEtag: '"9946687e5fa0dab5993ededddb398d2e"',
        httpMetadata: {},
        key: 'key1',
        size: 6,
      },
      {
        customMetadata: {},
        etag: 'f066ce9385512ee02afc6e14d627e9f2',
        httpEtag: '"f066ce9385512ee02afc6e14d627e9f2"',
        httpMetadata: {},
        key: 'key2',
        size: 6,
      },
      {
        customMetadata: {},
        etag: '039da699d091de4f1240ae50570abed9',
        httpEtag: '"039da699d091de4f1240ae50570abed9"',
        httpMetadata: {},
        key: 'key3',
        size: 6,
      },
      {
        customMetadata: {},
        etag: 'b600fc6b6ea1955d114861c42934c659',
        httpEtag: '"b600fc6b6ea1955d114861c42934c659"',
        httpMetadata: {},
        key: 'key4',
        size: 6,
      }
    ]
  })
})

it<LocalTestContext>('r2: r2object: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/r2/r2object')
  const obj: R2Object = await res.json()
  const copy = { ...obj }
  
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.isNotNull(copy.uploaded)
  assert.isTrue(typeof copy.uploaded === 'string')
  const date = new Date()
  copy.uploaded = date
  assert.isNotNull(copy.version)
  assert.isTrue(typeof copy.version === 'string')
  copy.version = ''
  assert.deepEqual(copy, {
    customMetadata: {},
    etag: '2063c1608d6e0baf80249c42e2be5804',
    httpEtag: '"2063c1608d6e0baf80249c42e2be5804"',
    httpMetadata: {},
    key: 'key',
    size: 5,
    uploaded: date,
    version: ''
  })
})

it<LocalTestContext>('r2: r2objectBody: put -> get -> return get result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/r2/r2object-body')
  const obj: R2Object = await res.json()
  const copy = { ...obj }
  
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.isNotNull(copy.uploaded)
  assert.isTrue(typeof copy.uploaded === 'string')
  const date = new Date()
  copy.uploaded = date
  assert.isNotNull(copy.version)
  assert.isTrue(typeof copy.version === 'string')
  copy.version = ''
  assert.deepEqual(copy, {
    customMetadata: {},
    etag: '2063c1608d6e0baf80249c42e2be5804',
    httpEtag: '"2063c1608d6e0baf80249c42e2be5804"',
    httpMetadata: {},
    key: 'key',
    range: {
      length: 3,
      offset: 2,
    },
    size: 5,
    uploaded: date,
    version: ''
  })
})
