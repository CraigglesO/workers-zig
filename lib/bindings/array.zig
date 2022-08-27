const common = @import("common.zig");
const jsCreateClass = common.jsCreateClass;
const jsFree = common.jsFree;
const jsSize = common.jsSize;
const Classes = common.Classes;
const Undefined = common.Undefined;
const String = @import("string.zig").String;

pub extern fn jsArrayPush(arrID: u32, args: u32) void;
pub extern fn jsArrayGet(arrID: u32, pos: u32) u32;

pub const Array = struct {
  id: u32,

  pub fn init (ptr: u32) Array {
    return Array{ .id = ptr };
  }

  pub fn new () Array {
    return Array{ .id = jsCreateClass(Classes.Array.toInt(), Undefined) };
  }

  pub fn free (self: *const Array) void {
    jsFree(self.id);
  }

  pub fn push (self: *const Array, ptr: u32) void {
    jsArrayPush(self.id, ptr);
  }

  pub fn get (self: *const Array, pos: u32) u32 {
    return jsArrayGet(self.id, pos);
  }

  pub fn getType (self: *const Array, comptime T: type, pos: u32) T {
    const id = jsArrayGet(self.id, pos);
    return T.init(id);
  }

  pub fn length (self: *const Array) u32 {
    return jsSize(self.id);
  }
};
