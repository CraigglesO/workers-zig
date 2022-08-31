import avaTest, { TestFn, ExecutionContext } from 'ava'
import { Miniflare } from 'd1testflare'

export interface Context {
  mf: Miniflare
}

const test = avaTest as TestFn<Context>

test.beforeEach(async (t: ExecutionContext<Context>) => {
  // Create a new Miniflare environment for each test
  const mf = new Miniflare({
    envPath: true,
    packagePath: true,
    wranglerConfigPath: true,
    buildCommand: undefined,
    modules: true,
    d1Databases: ['TEST_DB'],
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

test('d1: first: return result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/d1/first')
  // Check the body was returned
  t.is(res.status, 200)
  t.deepEqual(await res.json(), { CompanyName: 'Alfreds Futterkiste' })
})

test('d1: all: return result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/d1/all')
  const body: any = await res.json()
  // Check the body was returned
  t.is(res.status, 200)
  t.deepEqual(body.results, [{ CompanyName: 'Alfreds Futterkiste' }])
  t.deepEqual(body.lastRowId, null)
  t.deepEqual(body.changes, null)
  t.deepEqual(body.success, true)
  t.deepEqual(body.served_by, 'x-miniflare.db3')
  t.is(typeof body.duration, 'number')
})

// NOTE: Currently the return for raw is bugged?
// test('d1: raw: return result', async (t: ExecutionContext<Context>) => {
//   // Get the Miniflare instance
//   const { mf } = t.context
//   // Dispatch a fetch event to our worker
//   const res = await mf.dispatchFetch('http://localhost:8787/d1/raw')
//   const body: any = await res.json()
//   // Check the body was returned
//   t.is(res.status, 200)
//   t.deepEqual(body, ['Alfreds Futterkiste'])

//   // t.true(true)
//   // const db = await mf.getD1Database('TEST_DB')
//   // const stmt = db.prepare('SELECT CompanyName FROM Customers')
//   // const raw = await stmt.raw()
//   // console.log(raw)
// })

test('d1: run: return result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/d1/run')
  // Check the body was returned
  t.is(res.status, 200)
  
  const db = await mf.getD1Database('TEST_DB')
  const stmt = db.prepare('SELECT * FROM Customers WHERE CustomerID = ?')
  const dbRes = await stmt.bind(69).first()
  t.deepEqual(dbRes, { CustomerID: 69, CompanyName: 'S2Maps', ContactName: 'CTO' });
})

test('d1: batch: return result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/d1/batch')
  // Check the body was returned
  t.is(res.status, 200)
  
  const db = await mf.getD1Database('TEST_DB')
  const stmt = db.prepare('SELECT * FROM Customers')
  const dbRes = await stmt.all()
  t.deepEqual(dbRes.results, [
    { CustomerID: 1, CompanyName: 'Alfreds Futterkiste', ContactName: 'Maria Anders' },
    { CustomerID: 11, CompanyName: 'Bs Beverages', ContactName: 'Victoria Ashworth' },
    { CustomerID: 13, CompanyName: 'Bs Beverages', ContactName: 'Random Name' },
    { CustomerID: 69, CompanyName: 'S2Maps', ContactName: 'CTO' },
    { CustomerID: 70, CompanyName: 'Hi', ContactName: 'OTC' },
    { CustomerID: 71, CompanyName: 'Three', ContactName: 'Name' }
  ])
})

test('d1: exec: return result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // Dispatch a fetch event to our worker
  const res = await mf.dispatchFetch('http://localhost:8787/d1/exec')
  const body: any = await res.json();
  // Check the body was returned
  t.is(res.status, 200)
  t.is(body.count, 1)
  t.is(typeof body.duration, 'number')
})
