# Fetch

[Learn more via the developer docs](https://developers.cloudflare.com/workers/runtime-apis/fetch-event/)

## **Example**:

## ZIG

```zig
const std = @import("std");
const allocator = std.heap.page_allocator;
const eql = std.mem.eql;
const worker = @import("workers-zig");
const String = worker.String;
const FetchContext = worker.FetchContext;
const ScheduledContext = worker.ScheduledContext;
const Response = worker.Response;
const String = worker.String;
const Headers = worker.Headers;

// NOTE:
// https://github.com/ziglang/zig/issues/3160
// until @asyncCall WASM support is implemented we use a double-up function
export fn fetchEvent (ctxID: u32) void {
  // build the fetchContext
  const ctx = FetchContext.init(ctxID) catch {
    String.new("Unable to prepare a FetchContext.").throw();
    return;
  };
  // Build the async frame:
  const frame = allocator.create(@Frame(_fetchEvent)) catch {
      ctx.throw(500, "Unable to prepare a frame.");
      return undefined;
  };
  frame.* = async _fetchEvent(ctx);
  // tell the context about the frame for later destruction
  ctx.frame.* = frame;
}

fn _fetchEvent (ctx: *FetchContext) callconv(.Async) void {
  const path = ctx.path;

  // Try routes
  // ** BASIC **
  if (eql(u8, "basic", path)) return basicHandler(ctx);

  // If we make it here, throw.
  ctx.throw(500, "Route does not exist.");
}

pub fn basicHandler (ctx: *FetchContext) callconv(.Async) void {
    // get body from request
    const text = ctx.req.text() orelse return ctx.throw(500, "Failed to get body.");
    defer allocator.free(text);
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // body
    const body = String.new(text);
    defer body.free();
    // response
    const res = Response.new(
        .{ .string = &body },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}
```

## JS / TS Option 1 - Via fetch:

```ts
import { zigFetch } from 'workers-zig'

export interface Env {}

export default {
  fetch: zigFetch<Env>('basicFetch')
}
```

## JS / TS Option 2 - As a route:

```ts
import { Router } from 'itty-router'
import { zigFetch } from 'workers-zig'

export interface Env {}

const router = Router()
router.get('/', () => new Response('Hello from JS!'))
router.get('/basic', zigFetch<Env>('basicFetch'))

export default {
  fetch: router.handle
}
```
