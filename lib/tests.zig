const std = @import("std");
const allocator = std.heap.page_allocator;
const eql = std.mem.eql;
const worker = @import("workers-zig");
const String = worker.String;
const FetchContext = worker.FetchContext;

const basicHandler = @import("tests/basic.zig").basicHandler;
const kv = @import("tests/apis/kv.zig");
const cache = @import("tests/apis/cache.zig");

// NOTE:
// https://github.com/ziglang/zig/issues/3160
// until @asyncCall WASM support is implemented we use a double-up function
export fn fetchEvent (ctxID: u32) void {
  // build the fetchContext
  const ctx = worker.FetchContext.init(ctxID) catch {
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
  // ** CACHE **
  if (eql(u8, "cacheText", path)) return cache.cacheTextHandler(ctx);
  if (eql(u8, "cacheString", path)) return cache.cacheStringHandler(ctx);
  if (eql(u8, "cacheUnique", path)) return cache.cacheUniqueHandler(ctx);
  if (eql(u8, "cacheDelete", path)) return cache.cacheDeleteHandler(ctx);
  if (eql(u8, "cacheIgnoreText", path)) return cache.cacheIgnoreTextHandler(ctx);
  if (eql(u8, "cacheIgnoreDelete", path)) return cache.cacheIgnoreDeleteHandler(ctx);
  // ** KV **
  if (eql(u8, "kvString", path)) return kv.kvStringHandler(ctx);
  if (eql(u8, "kvText", path)) return kv.kvTextHandler(ctx);
  if (eql(u8, "kvObject", path)) return kv.kvObjectHandler(ctx);
  if (eql(u8, "kvJSON", path)) return kv.kvJSONHandler(ctx);
  if (eql(u8, "kvArraybuffer", path)) return kv.kvArraybufferHandler(ctx);
  if (eql(u8, "kvStream", path)) return kv.kvStreamHandler(ctx);
  if (eql(u8, "kvBytes", path)) return kv.kvBytesHandler(ctx);
  if (eql(u8, "kvDelete", path)) return kv.kvDeleteHandler(ctx);
  if (eql(u8, "kvList", path)) return kv.kvListHandler(ctx);

  // If we make it here, throw.
  ctx.throw(500, "Route does not exist.");
}
