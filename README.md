# Workers-Zig

![workers-zig](.github/workers-zig.svg)

**Workers Zig** is a light weight [**Zig**](https://ziglang.org/) bindings for the [**Cloudflare Workers**](https://workers.cloudflare.com/) environment via [**WebAssembly**](https://webassembly.org/).

Why Zig?
* Zig is a language that is designed to be a small, fast, and portable.
* The language already supports WASM and WASI.
* Small builds are easy to achieve. To expound on this, the basic example provided is `5.8Kb` of WASM code and `6.8Kb` javascript code.
* I wanted a tool that made it easy for both WASM and JS code to work in tandem.
* I didn't like that rust wasm bindings would grow the more code you wrote. I came up with a strategy that covers 90% use cases, JS glue doesn't grow, and you can add the 10% as needed.
* I prefer [**Zig's memory model**](https://www.scattered-thoughts.net/writing/how-safe-is-zig/) over Rust.


Be sure to read the [Documentation](https://github.com/CraigglesO/workers-zig/tree/master/docs) for guidance on usage.

## Features

- 🔗 Zero dependencies
- 🤝 Use in tandem with Javascript or 100% Zig WebAssembly
- 🎮 JS bindings with support to write your own - [List of supported bindings here](https://github.com/CraigglesO/workers-zig/tree/master/docs/bindings)
- 📨 Fetch bindings
- ⏰ Scheduled bindings
- 🔑 Supports Variables and Secrets from `env`
- ✨ Cache bindings
- 📦 KV bindings
- 🪣 R2 bindings
- 💾 D1 bindings
- 🔐 Web-Crypto bindings [partially complete]
- 💪 Uses TypeScript

## Features coming soon

- 🗿 WASI support
- 📌 Durable Objects bindings
- ✉️ WebSockets bindings
- once CF lands dynamic imports: Only load wasm when needed.

## Install

### Step 1: Install Zig

[Follow the instructions to install Zig](https://ziglang.org/learn/getting-started/)

Release used: **0.10.0-dev.3838+77f31ebbb**

### Step 2a: Use the skeleton project provided

[Follow the steps provided by the skeleton project](https://github.com/CraigglesO/worker-zig-template)

```bash
# in one go
git clone --recurse-submodules -j8 git@github.com:CraigglesO/worker-zig-template.git

# OR

# clone
git clone git@github.com:CraigglesO/worker-zig-template.git
# enter
cd worker-zig-template
# Pull in the submodule
git submodule update --init --recursive
```

### Step 2b: Install the workers-zig package

```bash
# NPM
npm install --save workers-zig
# Yarn
yarn add workers-zig
# PNPM
pnpm add workers-zig
# BUN
bun add workers-zig
```

### Step 3: Add workers-zig as a submodule to your project

```bash
git submodule add https://github.com/CraigglesO/workers-zig
```

### Step 4: Setup a **build.zig** script

### Step 5: Recommended wrangler configuration

```toml
name = "zig-worker-template"
main = "dist/worker.mjs"
compatibility_date = "2022-07-29"
usage_model = "bundled" # or unbound
account_id = ""

[build]
command = "zig build && npm run esbuild"
watch_dir = [
  "src",
  "lib"
]

[[build.upload.rules]]
type = "CompiledWasm"
globs = ["**/*.wasm"]
[[build.upload.rules]]
type = "ESModule"
globs = ["**/*.mjs"]
```
