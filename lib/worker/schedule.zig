const std = @import("std");
const allocator = std.heap.page_allocator;
const common = @import("../bindings/common.zig");
const jsFree = common.jsFree;
const jsResolve = common.jsResolve;
const Undefined = common.Undefined;
const True = common.True;
const ExecutionContext = @import("../bindings/executionContext.zig").ExecutionContext;
const Env = @import("../bindings/env.zig").Env;
const Request = @import("../bindings/request.zig").Request;
const Response = @import("../bindings/response.zig").Response;
const StatusCode = @import("../http/common.zig").StatusCode;
const String = @import("../bindings/string.zig").String;
const Function = @import("../bindings/function.zig").Function;
const getStringFree = @import("../bindings/string.zig").getStringFree;
const object = @import("../bindings/object.zig");
const getObjectValue = object.getObjectValue;
const getObjectValueNum = object.getObjectValueNum;

pub const ScheduleFn = fn (*ScheduledContext) void;

pub const ScheduledEvent = struct {
  id: u32,

  pub fn init (ptr: u32) ScheduledEvent {
    return ScheduledEvent{ .id = ptr };
  }

  pub fn free (self: *const ScheduledEvent) void {
    jsFree(self.id);
  }

  pub fn scheduledTime (self: *const ScheduledEvent) u64 {
    return getObjectValueNum(self.id, "scheduledTime", u64);
  }

  // NOTE: user must free the returned string from the allocator heap
  pub fn cron (self: *const ScheduledEvent) []const u8 {
    const jsPtr = getObjectValue(self.id, "cron");
    return getStringFree(jsPtr);
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1503
pub const ScheduledContext = struct {
  id: u32,
  event: ScheduledEvent,
  env: Env,
  exeContext: ExecutionContext,

  frame: *anyframe,

  pub fn init(
    id: u32
  ) !*ScheduledContext {
    var ctx = try allocator.create(ScheduledContext);
    errdefer allocator.destroy(ctx);

    ctx.* = .{
      .id = id,
      .event = ScheduledEvent.init(getObjectValue(id, "event")),
      .env = Env.init(getObjectValue(id, "env")),
      .exeContext = ExecutionContext.init(getObjectValue(id, "ctx")),
      .frame = undefined
    };

    return ctx;
  }

  pub fn deinit (self: *ScheduledContext) void {
    self.event.free();
    self.env.free();
    self.exeContext.free();
    jsFree(self.id);
    allocator.destroy(self.frame);
    allocator.destroy(self);
  }

  pub fn throw (self: *ScheduledContext, msg: []const u8) void {
    defer self.resolve();
    const throwStr = String.new(msg);
    defer throwStr.free();
    throwStr.throw();
  }

  pub fn resolve (self: *ScheduledContext) void {
    defer self.deinit();
    // call the resolver.
    jsResolve(self.id, Undefined);
  }
};
