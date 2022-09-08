import { copyFileSync, unlinkSync, readFileSync, writeFileSync } from 'fs'
import esbuild from 'esbuild'
import watPlugin from 'esbuild-plugin-wat'
import path from 'path'
import { fileURLToPath } from 'url'
import { minify } from 'uglify-js'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// BUNDLERS SUCK.
// no matter how convoluted, this works...

// step 1: migrate to dist folder
esbuild
  .buildSync({
    entryPoints: [
      './test/wasm.ts'
    ],
    format: 'esm',
    sourcemap: false,
    treeShaking: true,
    bundle: true,
    minify: false,
    outfile: './dist/tmp_worker.mjs',
    external: ['*.wasm', '@cloudflare/workers-wasi'],
  })

// step 2: copy __worker_zig_wasi.wasm and __worker_zig_wasm.wasm to dist
copyFileSync('./zig-out/lib/tests.wasm', './dist/__worker_zig_wasm.wasm')
copyFileSync('./zig-out/lib/tests_wasi.wasm', './dist/__worker_zig_wasi.wasm')

// step 3: final build
esbuild
  .build({
    entryPoints: [
      './dist/tmp_worker.mjs'
    ],
    format: 'esm',
    sourcemap: true,
    treeShaking: true,
    bundle: true,
    minify: false,
    outfile: './dist/worker.mjs',
    plugins: [
      watPlugin({
        loader: 'file'
      })
    ]
  })
  .then(() => {
    // cleanup tmp files
    unlinkSync('./dist/tmp_worker.mjs')
    unlinkSync('./dist/__worker_zig_wasm.wasm')
    unlinkSync('./dist/__worker_zig_wasi.wasm')
  })
  .then(() => {
    stepFour()
  })
  .catch(() => process.exit(1))

// step 4: read line-by-line. If line includes a .wasm file, convert to import
function stepFour () {
  const file = readFileSync('./dist/worker.mjs', 'utf8')
  const lines = file.split('\n')
  for (let i = 0, ll = lines.length; i < ll; i++) {
    const line = lines[i]
    if (line.includes('.wasm"')) {
      lines[i] = line.replace('var', 'import').replace('=', 'from')
    }
  }
  const { code } = minify(lines.join('\n'))
  writeFileSync('./dist/worker.mjs', code)
}