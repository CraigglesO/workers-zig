const std = @import("std");
const Function = @import("function.zig").Function;
const jsFree = @import("common.zig").jsFree;

pub const WaitUntilFn = fn () callconv(.Async) void;

// returns a pointer to the resolve function
pub extern fn jsWaitUntil (ctxPtr: u32) u32;
pub extern fn jsWaitUntilResolve (resolvePtr: u32) void;
pub extern fn jsPassThroughOnException (ctxPtr: u32) void;

pub const ExecutionContext = struct {
  id: u32,
  
  pub fn init (ptr: u32) ExecutionContext {
    return ExecutionContext{ .id = ptr };
  }

  pub fn free (self: *const ExecutionContext) void {
    jsFree(self.id);
  }

  pub fn waitUntil (self: *const ExecutionContext, waitFn: WaitUntilFn) void {
    const resolveFn = Function.init(jsWaitUntil(self.id));
    waitFn();
    resolveFn.call();
  }

  pub fn passThroughOnException (self: *const ExecutionContext) void {
    jsPassThroughOnException(self.id);
  }
};
