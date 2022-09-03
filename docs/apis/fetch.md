# Fetch

[Learn more via the developer docs](https://developers.cloudflare.com/workers/runtime-apis/cache/)

## fetch
```zig
pub fn fetch (request: RequestInfo, requestInit: ?RequestOptions) callconv(.Async) Response
```

[RequestInfo](https://github.com/CraigglesO/workers-zig/blob/master/lib/bindings/request.zig#L79)
[RequestOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/bindings/request.zig#L101)
[Response](https://github.com/CraigglesO/workers-zig/blob/master/lib/bindings/response.zig#L63)


## example

```zig
pub fn fetchHandler (ctx: *FetchContext) callconv(.Async) void {
    // fetch from local
    const localRes = fetch(.{ .text = "http://localhost:8787/kv/text" }, null);
    defer localRes.free();

    ctx.send(&localRes);
}
```
