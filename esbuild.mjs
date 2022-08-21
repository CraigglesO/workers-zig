import fs from 'fs'
import path from 'path'
import esbuild from 'esbuild'

esbuild
  .build({
    entryPoints: [
      './test/index.ts'
    ],
    format: 'esm',
    sourcemap: false,
    treeShaking: true,
    bundle: true,
    minify: true,
    outfile: './dist/worker.js',
  })
  .then(() => {
    const code = fs.readFileSync('./dist/worker.js', 'utf8')

    fs.writeFileSync('./dist/worker.js', 'import __WORKER_ZIG_WASM from "./tests.wasm";' + code, 'utf8')
  })
  .catch(() => process.exit(1))
