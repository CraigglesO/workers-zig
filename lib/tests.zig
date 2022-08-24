const worker = @import("workers-zig");
const Router = worker.Router;
const String = worker.String;
const HandlerFn = worker.HandlerFn;
const post = worker.post;

const basicHandler = @import("tests/basic.zig").basicHandler;
const kv = @import("tests/apis/kv.zig");

export fn fetchEvent () *anyopaque {
  const router = Router.init(.{
    comptime post("basic", basicHandler),
    // ** KV **
    comptime post("kvString", kv.kvStringHandler),
    comptime post("kvText", kv.kvTextHandler),
    comptime post("kvObject", kv.kvObjectHandler),
    comptime post("kvJSON", kv.kvJSONHandler),
    comptime post("kvArraybuffer", kv.kvArraybufferHandler),
    comptime post("kvStream", kv.kvStreamHandler),
    comptime post("kvBytes", kv.kvBytesHandler),
    comptime post("kvDelete", kv.kvDeleteHandler),
  }) catch {
    String.new("Failed to create router").throw();
    return undefined;
  };

  return router;
}

// **APIS**
// usingnamespace @import("tests/apis/kv.zig");
