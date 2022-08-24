const worker = @import("workers-zig");
const Router = worker.Router;
const String = worker.String;
const HandlerFn = worker.HandlerFn;
const post = worker.post;

const basicHandler = @import("tests/basic.zig").basicHandler;

export fn main () *anyopaque {
  const router = Router.init(.{
    post("basic", basicHandler),
  }) catch {
    String.new("Failed to create router").throw();
    return undefined;
  };

  return router;
}

// **APIS**
// usingnamespace @import("tests/apis/kv.zig");
