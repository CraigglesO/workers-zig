const std = @import("std");
const common = @import("common.zig");
const Undefined = common.Undefined;
const Array = @import("array.zig").Array;
const String = @import("string.zig").String;

extern fn jsFnCall(fnPtr: u32, argsPtr: u32) u32;
extern fn jsAsyncFnCall(frame: *anyopaque, funcPtr: u32, argsPtr: u32, resPtr: *u32) void;
pub fn jsAsync(funcPtr: u32, argsPtr: u32) u32 {
  var res: u32 = 0;
  suspend {
    jsAsyncFnCall(@frame(), funcPtr, argsPtr, &res);      
  }
  return res;
}

pub const Function = struct {
  id: u32,

  pub fn init (ptr: u32) Function {
    return Function{ .id = ptr };
  }

  pub fn free (self: *const Function) void {
    common.jsFree(self.id);
  }

  pub fn call (self: *const Function, argsPtr: u32) u32 {
    return jsFnCall(self.id, argsPtr);
  }
};

pub const AsyncFunction = struct {
  id: u32,

  pub fn init (ptr: u32) AsyncFunction {
    return AsyncFunction{ .id = ptr };
  }

  pub fn free (self: *const AsyncFunction) void {
    common.jsFree(self.id);
  }

  pub fn call (self: *const AsyncFunction, argsPtr: u32) callconv(.Async) u32 {
    return await async jsAsync(self.id, argsPtr);
  }
};
