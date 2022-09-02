# Cache

[Learn more via the developer docs](https://developers.cloudflare.com/workers/runtime-apis/cache/)

## Importing

```zig
const worker = @import("workers-zig");
const Cache = worker.Cache;
```

## new
```zig
pub fn new (options: CacheOptions) Cache
```

[CacheOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/cache.zig#L24)

## put
```zig
pub fn put (
  self: *const Cache,
  req: RequestInfo,
  res: *const Response
) void
```

[RequestInfo](https://github.com/CraigglesO/workers-zig/blob/master/lib/bindings/request.zig#L79)
[Response](https://github.com/CraigglesO/workers-zig/blob/master/lib/bindings/response.zig#L63)

## match
```zig
pub fn match (
  self: *const Cache,
  req: RequestInfo,
  options: CacheQueryOptions
) ?Response
```

[RequestInfo](https://github.com/CraigglesO/workers-zig/blob/master/lib/bindings/request.zig#L79)
[CacheQueryOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/cache.zig#L46)

## delete
```zig
pub fn delete (
  self: *const Cache,
  req: RequestInfo,
  options: CacheQueryOptions
) bool
```

[RequestInfo](https://github.com/CraigglesO/workers-zig/blob/master/lib/bindings/request.zig#L79)
[CacheQueryOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/cache.zig#L46)

---

## example

```zig
pub fn cacheTextHandler (ctx: *FetchContext) callconv(.Async) void {
    const url = "http://localhost/cacheTest";
    // get the kvinstance from env
    const cache = Cache.new(.none);
    defer cache.free();
    // store the request with cache control headers
    const cacheHeaders = Headers.new();
    defer cacheHeaders.free();
    cacheHeaders.setText("Cache-Control", "max-age=3600");
    cacheHeaders.setText("Content-Type", "text/plain");
    const cacheRes = Response.new(
      .{ .text = "cached response" },
      .{ .status = 200, .statusText = "ok", .headers = &cacheHeaders }
    );
    defer cacheRes.free();
    cache.put(.{ .text = url }, &cacheRes);
    // response
    const res = cache.match(.{ .text = url }, .{}) orelse return ctx.throw(500, "failed to get cache");
    defer res.free();

    ctx.send(&res);
}
```
