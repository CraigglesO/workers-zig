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
  console.log('HERHEHREHR')

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
  const body = await res.json()
  // const clone = { ...body }
  // Check the body was returned
  t.is(res.status, 200)
  t.deepEqual(body.results, [ { CompanyName: 'Alfreds Futterkiste' } ])
  t.deepEqual(body.lastRowId, null)
  t.deepEqual(body.changes, null)
  t.deepEqual(body.success, true)
  t.deepEqual(body.served_by, 'x-miniflare.db3')
  t.is(typeof body.duration, 'number')
})
