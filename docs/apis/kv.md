# KVNamespace

[Learn more via the developer docs](https://developers.cloudflare.com/workers/runtime-apis/kv/)

## put
```zig
pub fn put (
  self: *const KVNamespace,
  key: []const u8,
  value: PutValue,
  options: PutOptions
) void
```

[PutValue](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L35)
[PutOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L65)

## putMetadata
```zig
pub fn putMetadata (
  self: *const KVNamespace,
  key: []const u8,
  value: PutValue,
  comptime T: type,
  metadata: T,
  options: PutOptions
) void
```

[PutValue](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L35)
[PutOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L65)

## getString
```zig
pub fn getString (
  self: *const KVNamespace,
  key: []const u8,
  options: GetOptions
) ?String
```

[GetOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L23)
[String](https://github.com/CraigglesO/workers-zig/blob/master/lib/bindings/string.zig#L21)

## getString
```zig
pub fn getStringWithMetadata (
  self: *const KVNamespace,
  key: []const u8,
  options: GetOptions
) ?KVStringMetadata
```

[GetOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L23)
[KVStringMetadata](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L338)

## getText
```zig
pub fn getText (
  self: *const KVNamespace,
  key: []const u8,
  options: GetOptions
) ?[]const u8
```

[GetOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L23)

## getTextWithMetadata
```zig
pub fn getTextWithMetadata (
  self: *const KVNamespace,
  key: []const u8,
  options: GetOptions
) ?KVTextMetadata
```

[GetOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L23)
[KVTextMetadata](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L379)

## getObject
```zig
pub fn getObject (
  self: *const KVNamespace,
  key: []const u8,
  options: GetOptions
) ?Object
```

[GetOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L23)
[Object](https://github.com/CraigglesO/workers-zig/blob/master/lib/bindings/object.zig#L75)

## getObjectWithMetadata
```zig
pub fn getObjectWithMetadata (
  self: *const KVNamespace,
  key: []const u8,
  options: GetOptions
) ?KVObjectMetadata
```

[GetOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L23)
[KVObjectMetadata](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L417)

## getJSON
```zig
pub fn getJSON (
  self: *const KVNamespace,
  comptime T: type,
  key: []const u8,
  options: GetOptions
) ?T
```

[GetOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L23)

## getArrayBuffer
```zig
pub fn getArrayBuffer (
  self: *const KVNamespace,
  key: []const u8,
  options: GetOptions
) ?ArrayBuffer
```

[GetOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L23)
[ArrayBuffer](https://github.com/CraigglesO/workers-zig/blob/master/lib/bindings/arraybuffer.zig#L10)

## getArrayBufferWithMetadata
```zig
pub fn getArrayBufferWithMetadata (
  self: *const KVNamespace,
  key: []const u8,
  options: GetOptions
) ?KVArrayBufferMetadata
```

[GetOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L23)
[KVArrayBufferMetadata](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L477)

## getBytes
```zig
pub fn getBytes (
  self: *const KVNamespace,
  key: []const u8,
  options: GetOptions
) ?[]const u8
```

[GetOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L23)

## getBytes
```zig
pub fn getStream (
  self: *const KVNamespace,
  key: []const u8,
  options: GetOptions
) ?ReadableStream
```

[GetOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L23)
[ReadableStream](https://github.com/CraigglesO/workers-zig/blob/master/lib/bindings/streams/readable.zig#L37)

## getBytes
```zig
pub fn getStreamWithMetadata (
  self: *const KVNamespace,
  key: []const u8,
  options: GetOptions
) ?KVStreamMetadata
```

[GetOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L23)
[KVStreamMetadata](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L557)

## delete
```zig
pub fn delete (
  self: *const KVNamespace,
  key: []const u8
) void
```

## list
```zig
pub fn list (self: *const KVNamespace, options: ListOptions) ListResult
```

[ListOptions](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L82)
[ListResult](https://github.com/CraigglesO/workers-zig/blob/master/lib/apis/kv.zig#L103)

---

## example

```zig
pub fn kvStringHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();
    // create a js string to use
    const jsStr = String.new("value");
    defer jsStr.free();
    kv.put("key", .{ .string = &jsStr }, .{});
    const text = kv.getString("key", .{}) orelse {
        ctx.throw(500, "Could not find KV key's value");
        return;
    };
    defer text.free();
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .string = &text },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}
```
