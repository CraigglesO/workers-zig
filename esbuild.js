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
      './test/index.ts'
    ],
    format: 'esm',
    sourcemap: false,
    treeShaking: true,
    bundle: true,
    minify: false,
    outfile: './dist/tmp_worker.mjs',
    external: ['*.wasm'],
  })

// step 2: copy zigWASM and zigWASI to dist
copyFileSync('./zig-out/lib/zigWASM.wasm', './dist/zigWASM.wasm')
copyFileSync('./zig-out/lib/zigWASI.wasm', './dist/zigWASI.wasm')
copyFileSync('./memfs.wasm', './dist/memfs.wasm')

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
    unlinkSync('./dist/zigWASM.wasm')
    unlinkSync('./dist/zigWASI.wasm')
    unlinkSync('./dist/memfs.wasm')
  })
  .then(() => {
    stepFour()
  })
  .catch((err) => { console.log(err); process.exit(1) })

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