const std = @import("std");
const allocator = std.heap.page_allocator;
const eql = std.mem.eql;
const worker = @import("workers-zig");
const String = worker.String;
const FetchContext = worker.FetchContext;
const ScheduledContext = worker.ScheduledContext;

const Object = worker.Object;

const basicHandler = @import("tests/basic.zig").basicHandler;
const argon = @import("tests/crypto/argon.zig");
const cache = @import("tests/apis/cache.zig");
const fetch = @import("tests/apis/fetch.zig");
const kv = @import("tests/apis/kv.zig");
const r2 = @import("tests/apis/r2.zig");
const d1 = @import("tests/apis/d1.zig");

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
  // ** CRYPTO **
  if (eql(u8, "argonHash", path)) return argon.argonHashHandler(ctx);
  // ** CACHE **
  if (eql(u8, "cacheText", path)) return cache.cacheTextHandler(ctx);
  if (eql(u8, "cacheString", path)) return cache.cacheStringHandler(ctx);
  if (eql(u8, "cacheUnique", path)) return cache.cacheUniqueHandler(ctx);
  if (eql(u8, "cacheDelete", path)) return cache.cacheDeleteHandler(ctx);
  if (eql(u8, "cacheIgnoreText", path)) return cache.cacheIgnoreTextHandler(ctx);
  if (eql(u8, "cacheIgnoreDelete", path)) return cache.cacheIgnoreDeleteHandler(ctx);
  // ** FETCH **
  if (eql(u8, "fetch", path)) return fetch.fetchHandler(ctx);
  // ** KV **
  if (eql(u8, "kvString", path)) return kv.kvStringHandler(ctx);
  if (eql(u8, "kvStringMeta", path)) return kv.kvStringWithMetadataHandler(ctx);
  if (eql(u8, "kvText", path)) return kv.kvTextHandler(ctx);
  if (eql(u8, "kvTextMeta", path)) return kv.kvTextWithMetadataHandler(ctx);
  if (eql(u8, "kvTextExpireTtl", path)) return kv.kvTextWithExpireTtlHandler(ctx);
  if (eql(u8, "kvTextExpire", path)) return kv.kvTextWithExpireHandler(ctx);
  if (eql(u8, "kvTextCacheTtl", path)) return kv.kvTextCacheTtlHandler(ctx);
  if (eql(u8, "kvObject", path)) return kv.kvObjectHandler(ctx);
  if (eql(u8, "kvObjectMeta", path)) return kv.kvObjectWithMetadataHandler(ctx);
  if (eql(u8, "kvJSON", path)) return kv.kvJSONHandler(ctx);
  if (eql(u8, "kvArraybuffer", path)) return kv.kvArraybufferHandler(ctx);
  if (eql(u8, "kvArraybufferMeta", path)) return kv.kvArrayBufferWithMetadataHandler(ctx);
  if (eql(u8, "kvStream", path)) return kv.kvStreamHandler(ctx);
  if (eql(u8, "kvStreamMeta", path)) return kv.kvStreamWithMetadataHandler(ctx);
  if (eql(u8, "kvBytes", path)) return kv.kvBytesHandler(ctx);
  if (eql(u8, "kvBytesMeta", path)) return kv.kvBytesWithMetadataHandler(ctx);
  if (eql(u8, "kvDelete", path)) return kv.kvDeleteHandler(ctx);
  if (eql(u8, "kvList", path)) return kv.kvListHandler(ctx);
  // ** R2 **
  if (eql(u8, "r2Stream", path)) return r2.r2StreamHandler(ctx);
  if (eql(u8, "r2Text", path)) return r2.r2TextHandler(ctx);
  if (eql(u8, "r2String", path)) return r2.r2StringHandler(ctx);
  if (eql(u8, "r2ArrayBuffer", path)) return r2.r2ArrayBufferHandler(ctx);
  if (eql(u8, "r2Bytes", path)) return r2.r2BytesHandler(ctx);
  if (eql(u8, "r2Object", path)) return r2.r2ObjectHandler(ctx);
  if (eql(u8, "r2JSON", path)) return r2.r2JSONHandler(ctx);
  if (eql(u8, "r2Head", path)) return r2.r2HeadHandler(ctx);
  if (eql(u8, "r2Delete", path)) return r2.r2DeleteHandler(ctx);
  if (eql(u8, "r2List", path)) return r2.r2ListHandler(ctx);
  if (eql(u8, "r2R2Object", path)) return r2.r2R2ObjectHandler(ctx);
  if (eql(u8, "r2R2ObjectBody", path)) return r2.r2R2ObjectBodyHandler(ctx);
  // ** D1 **
  if (eql(u8, "d1First", path)) return d1.d1FirstHandler(ctx);
  if (eql(u8, "d1All", path)) return d1.d1AllHandler(ctx);
  if (eql(u8, "d1Raw", path)) return d1.d1RawHandler(ctx);
  if (eql(u8, "d1Run", path)) return d1.d1RunHandler(ctx);
  if (eql(u8, "d1Batch", path)) return d1.d1BatchHandler(ctx);
  if (eql(u8, "d1Exec", path)) return d1.d1ExecHandler(ctx);

  // If we make it here, throw.
  ctx.throw(500, "Route does not exist.");
}

// NOTE:
// https://github.com/ziglang/zig/issues/3160
// until @asyncCall WASM support is implemented we use a double-up function
export fn scheduledEvent (ctxID: u32) void {
  // build the fetchContext
  const ctx = ScheduledContext.init(ctxID) catch {
    String.new("Unable to prepare a ScheduledContext.").throw();
    return;
  };
  // Build the async frame:
  const frame = allocator.create(@Frame(scheduledHandler)) catch {
      ctx.throw("Unable to prepare a frame.");
      return undefined;
  };
  frame.* = async scheduledHandler(ctx);
  // tell the context about the frame for later destruction
  ctx.frame.* = frame;
}

pub fn scheduledHandler (ctx: *ScheduledContext) callconv(.Async) void {
  // get the kvinstance from env
  const kvNamespace = ctx.env.kv("TEST_NAMESPACE") orelse {
    ctx.throw("Could not find \"TEST_NAMESPACE\"");
    return;
  };
  defer kvNamespace.free();

  // prep an object to store
  const obj = Object.new();
  defer obj.free();

  // get ctx cron string
  const cron = ctx.event.cron();
  defer allocator.free(cron);
  obj.setText("cron", cron);

  // get scheduled time
  const scheduledTime = ctx.event.scheduledTime();
  obj.setNum("scheduledTime", u64, scheduledTime);

  // store obj in kv
  kvNamespace.put("obj", .{ .object = &obj }, .{});

  ctx.resolve();
}
