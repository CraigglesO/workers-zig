import { beforeEach, afterEach, it, assert } from 'vitest'
import { Miniflare } from 'd1testflare'

interface LocalTestContext {
  mf: Miniflare
}

beforeEach<LocalTestContext>(async (ctx) => {
  // Create a new Miniflare environment for each test
  const mf = ctx.mf = new Miniflare({
    envPath: true,
    packagePath: true,
    wranglerConfigPath: true,
    buildCommand: undefined,
    modules: true,
    d1Databases: ['TEST_DB'],
    scriptPath: 'dist/worker.mjs',
  })
  // prep the db
  const db = await mf.getD1Database('TEST_DB')
  db.exec('CREATE TABLE Customers (CustomerID INT PRIMARY KEY, CompanyName TEXT, ContactName TEXT);')
  const stmt = db.prepare('INSERT INTO Customers (CustomerID, CompanyName, ContactName) VALUES (?, ?, ?)')
  await db.batch([
    stmt.bind(1, 'Alfreds Futterkiste', 'Maria Anders'),
    stmt.bind(11, 'Bs Beverages', 'Victoria Ashworth'),
    stmt.bind(13, 'Bs Beverages', 'Random Name'),
  ]).catch(err => console.error(err))
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

it<LocalTestContext>('d1: first: return result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/d1/first')
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(await res.json(), { CompanyName: 'Alfreds Futterkiste' })
})

it<LocalTestContext>('d1: all: return result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/d1/all')
  const body: any = await res.json()
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.deepEqual(body.results, [{ CompanyName: 'Alfreds Futterkiste' }])
  assert.deepEqual(body.lastRowId, null)
  assert.deepEqual(body.changes, null)
  assert.deepEqual(body.success, true)
  assert.deepEqual(body.served_by, 'x-miniflare.db3')
  assert.equal(typeof body.duration, 'number')
})

// NOTE: Currently the return for raw is bugged?
// it<LocalTestContext>('d1: raw: return result', async ({ mf }) => {
//   // Get the Miniflare instance
//   const { mf } = t.context
//   // Dispatch a fetch event to our worker
//   const res = await mf.dispatchFetch('http://localhost:8787/d1/raw')
//   const body: any = await res.json()
//   // Check the body was returned
//   assert.equal(res.status, 200)
//   assert.deepEqual(body, ['Alfreds Futterkiste'])

//   // t.true(true)
//   // const db = await mf.getD1Database('TEST_DB')
//   // const stmt = db.prepare('SELECT CompanyName FROM Customers')
//   // const raw = await stmt.raw()
//   // console.log(raw)
// })

it<LocalTestContext>('d1: run: return result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/d1/run')
  // Check the body was returned
  assert.equal(res.status, 200)
  
  const db = await mf.getD1Database('TEST_DB')
  const stmt = db.prepare('SELECT * FROM Customers WHERE CustomerID = ?')
  const dbRes = await stmt.bind(69).first()
  assert.deepEqual(dbRes, { CustomerID: 69, CompanyName: 'S2Maps', ContactName: 'CTO' });
})

it<LocalTestContext>('d1: batch: return result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/d1/batch')
  // Check the body was returned
  assert.equal(res.status, 200)
  
  const db = await mf.getD1Database('TEST_DB')
  const stmt = db.prepare('SELECT * FROM Customers')
  const dbRes = await stmt.all()
  assert.deepEqual(dbRes.results, [
    { CustomerID: 1, CompanyName: 'Alfreds Futterkiste', ContactName: 'Maria Anders' },
    { CustomerID: 11, CompanyName: 'Bs Beverages', ContactName: 'Victoria Ashworth' },
    { CustomerID: 13, CompanyName: 'Bs Beverages', ContactName: 'Random Name' },
    { CustomerID: 69, CompanyName: 'S2Maps', ContactName: 'CTO' },
    { CustomerID: 70, CompanyName: 'Hi', ContactName: 'OTC' },
    { CustomerID: 71, CompanyName: 'Three', ContactName: 'Name' }
  ])
})

it<LocalTestContext>('d1: exec: return result', async ({ mf }) => {
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/d1/exec')
  const body: any = await res.json();
  // Check the body was returned
  assert.equal(res.status, 200)
  assert.equal(body.count, 1)
  assert.equal(typeof body.duration, 'number')
})
