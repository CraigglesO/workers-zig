import { WASI } from '@cloudflare/workers-wasi'
// @ts-expect-error: external import
import __WORKER_ZIG_WASI from './__worker_zig_wasi.wasm'

import type { FetchContext } from './worker'

export async function wasiFetch (fetchCtx: FetchContext) {
  const { path, req, ctx } = fetchCtx
  const args: string[] = await req.json()
  args.unshift(path)

  // Creates a TransformStream we can use to pipe our stdout to our response body.
  const stdout = new TransformStream()
  const wasi = new WASI({
    args,
    stdout: stdout.writable,
  })

  // Instantiate our WASM with our demo module and our configured WASI import.
  const instance = new WebAssembly.Instance(__WORKER_ZIG_WASI, {
    wasi_snapshot_preview1: wasi.wasiImport,
  })

  // Keep our worker alive until the WASM has finished executing.
  ctx.waitUntil(wasi.start(instance))

  // Finally, let's reply with the WASM's output.
  return new Response(stdout.readable)
}
