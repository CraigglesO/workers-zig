const std = @import("std");
const allocator = std.heap.page_allocator;
const common = @import("../bindings/common.zig");
const jsFree = common.jsFree;
const jsResolve = common.jsResolve;
const ExecutionContext = @import("../bindings/executionContext.zig").ExecutionContext;
const Env = @import("../bindings/env.zig").Env;
const Request = @import("../bindings/request.zig").Request;
const Response = @import("../bindings/response.zig").Response;
const StatusCode = @import("../http/common.zig").StatusCode;
const String = @import("../bindings/string.zig").String;
const getStringFree = @import("../bindings/string.zig").getStringFree;
const getObjectValue = @import("../bindings/object.zig").getObjectValue;

const Object = @import("../bindings/object.zig").Object;
const jsStringLog = @import("../bindings/string.zig").jsStringLog;
const basicHandler = @import("../tests/basic.zig").basicHandler;

pub const HandlerFn = fn (ctx: *FetchContext) void;

pub const Route = struct {
  path: []const u8,
  method: ?[]const u8 = null,
  handle: HandlerFn,
};

pub const FetchContext = struct {
  id: u32,
  req: Request,
  env: Env,
  exeContext: ExecutionContext,
  path: []const u8,

  frame: *anyframe,

  pub fn init(
    id: u32
  ) !*FetchContext {
    var ctx = try allocator.create(FetchContext);
    errdefer allocator.destroy(ctx);

    ctx.* = .{
      .id = id,
      .req = Request.init(getObjectValue(id, "req")),
      .env = Env.init(getObjectValue(id, "env")),
      .exeContext = ExecutionContext.init(getObjectValue(id, "ctx")),
      .path = getStringFree(getObjectValue(id, "path")),
      .frame = undefined
    };

    return ctx;
  }

  pub fn deinit (self: *FetchContext) void {
    self.req.free();
    self.env.free();
    self.exeContext.free();
    jsFree(self.id);
    allocator.destroy(self.frame);
    allocator.destroy(self);
  }

  pub fn throw (self: *FetchContext, status: u16, msg: []const u8) void {
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

  pub fn send (self: *FetchContext, res: *const Response) void {
    defer self.deinit();
    // call the resolver.
    jsResolve(self.id, res.id);
  }
};

pub const Router = struct {
  routes: []const Route,

  pub fn init (comptime routes: anytype) !*Router {
    var fetchMap = try allocator.create(Router);
    errdefer allocator.destroy(fetchMap);

    comptime var rs: []const Route = &[_]Route{};
    inline for (routes) |handler| {
      switch (@TypeOf(handler)) {
        Route => {
          rs = (rs ++ &[_]Route{handler});
        },
        else => |f_type| String.new("unsupported handler type " ++ @typeName(f_type)).throw(),
      }
    }

    fetchMap.* = .{ .routes = rs };

    return fetchMap;
  }

  pub fn deinit (self: *const Router) void {
    allocator.free(self);
  }

  pub fn handleRequest (self: *const Router, ctx: *FetchContext) void {
    for (self.routes) |route| {
      if (std.mem.eql(u8, route.path, ctx.path)) {
        // const obj = Object.new();
        // obj.setNum("a", @intToFloat(f64, @ptrToInt(route.handle)));
        // jsStringLog(obj.id);
        return basicHandler(ctx);
        // return route.handle(ctx);
      }
    }

    ctx.throw(500, "Route does not exist.");
  }
};

pub fn get(path: []const u8, handler: HandlerFn) Route {
  return Route{
    .path = path,
    .method = "GET",
    .handle = @ptrCast(HandlerFn, handler),
  };
}

pub fn post(path: []const u8, handler: HandlerFn) Route {
  return Route{
    .path = path,
    .method = "POST",
    .handle = @ptrCast(HandlerFn, handler),
  };
}
