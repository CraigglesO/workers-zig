const common = @import("common.zig");
const jsCreateClass = common.jsCreateClass;
const jsFree = common.jsFree;
const jsSize = common.jsSize;
const Classes = common.Classes;
const Undefined = common.Undefined;
const String = @import("string.zig").String;

pub extern fn jsArrayPush(arrId: u32, args: u32) void;

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

  pub fn length (self: *const Array) u32 {
    return jsSize(self.id);
  }
};
