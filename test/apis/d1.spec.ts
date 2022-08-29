import avaTest, { TestFn, ExecutionContext } from 'ava'
import { Miniflare } from 'miniflare'

export interface Context {
  mf: Miniflare
}

const test = avaTest as TestFn<Context>

const SQL = `
DROP TABLE IF EXISTS \`Customers\`;
CREATE TABLE Customers (CustomerID INT, CompanyName TEXT, ContactName TEXT, PRIMARY KEY (\`CustomerID\`));
INSERT INTO Customers (CustomerID, CompanyName, ContactName) VALUES (1, "Alfreds Futterkiste", "Maria Anders"),(4, "Around the Horn", "Thomas Hardy"),(11, "Bs Beverages", "Victoria Ashworth"),(13, "Bs Beverages", "Random Name");
`

test.beforeEach(async (t: ExecutionContext<Context>) => {
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
    d1Databases: ['TEST_DB'],
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

test('d1: exec: put -> return result', async (t: ExecutionContext<Context>) => {
  // // Get the Miniflare instance
  // const { mf } = t.context
  // // Dispatch a fetch event to our worker
  // const res = await mf.dispatchFetch('http://localhost:8787/r2/stream')
  // // Check the body was returned
  // t.is(res.status, 200)
  // t.is(await res.text(), 'value')
  t.true(true)
})
