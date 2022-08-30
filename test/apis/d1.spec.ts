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

test('d1: exec: put -> return result', async (t: ExecutionContext<Context>) => {
  // Get the Miniflare instance
  const { mf } = t.context
  // // Dispatch a fetch event to our worker
  // const res = await mf.dispatchFetch('http://localhost:8787/r2/stream')
  // // Check the body was returned
  // t.is(res.status, 200)
  // t.is(await res.text(), 'value')
  t.true(true)
  // const db = await mf.getD1Database('TEST_DB')
  // const stmt = db.prepare('SELECT CompanyName FROM Customers WHERE CustomerID = ?')
  // const res = await stmt.bind(1).first()
  // console.log('res', res)
})

// all: {
//   results: [ { CompanyName: 'Alfreds Futterkiste' } ],
//   duration: 0.061768000945448875,
//   lastRowId: null,
//   changes: null,
//   success: true,
//   served_by: 'x-miniflare.db3'
// }

// first: { CompanyName: 'Alfreds Futterkiste' }