const std = @import("std");
const allocator = std.heap.page_allocator;
const jsFree = @import("../bindings/common.zig").jsFree;
const ExecutionContext = @import("../bindings/executionContext.zig").ExecutionContext;
const Env = @import("../bindings/env.zig").Env;
const Request = @import("../bindings/request.zig").Request;
const Response = @import("../bindings/response.zig").Response;
const StatusCode = @import("../http/common.zig").StatusCode;
const String = @import("../bindings/string.zig").String;
const getObjectValue = @import("../bindings/object.zig").getObjectValue;

extern fn jsResolve(ctx: u32, response: u32) void;

pub const HandlerFn = fn handle(*Context) callconv(.Async) void;

pub const Context = struct {
  id: u32,
  req: Request,
  env: Env,
  exeContext: ExecutionContext,

  frame: *anyframe,

  pub fn init(
    id: u32
  ) !*Context {
    var ctx = try allocator.create(Context);
    errdefer allocator.destroy(ctx);

    ctx.* = .{
      .id = id,
      .req = Request.init(getObjectValue(id, "req")),
      .env = Env.init(getObjectValue(id, "env")),
      .exeContext = ExecutionContext.init(getObjectValue(id, "ctx")),
      .frame = undefined
    };

    return ctx;
  }

  pub fn deinit (self: *Context) void {
    self.req.free();
    self.env.free();
    self.exeContext.free();
    jsFree(self.id);
    allocator.destroy(self.frame);
    allocator.destroy(self);
  }

  pub fn throw (self: *Context, status: u16, msg: []const u8) void {
    const statusText = @intToEnum(StatusCode, status).toString();

    // body
    const body = String.new(msg);
    defer body.free();
    // response
    const res = Response.new(
        .{ .string = &body },
        .{ .status = status, .statusText = statusText }
    );
    defer res.free();

    self.send(&res);
  }

  pub fn send (self: *Context, res: *const Response) void {
    defer self.deinit();
    // call the resolver.
    jsResolve(self.id, res.id);
  }
};
