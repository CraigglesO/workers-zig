import fs from 'fs'
import path from 'path'
import esbuild from 'esbuild'

esbuild
  .buildSync({
    entryPoints: [
      './test/wasi.ts'
    ],
    format: 'esm',
    sourcemap: true,
    treeShaking: true,
    bundle: true,
    minify: true,
    outfile: './dist/workerWASI.mjs',
    external: ['*.wasm']
  })

