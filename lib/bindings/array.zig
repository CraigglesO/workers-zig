const common = @import("common.zig");
const String = @import("string.zig").String;

extern fn jsArrayNew() u32;
extern fn jsArrayPush(arrId: u32, args: u32) void;

pub const Array = struct {
  id: u32,

  pub fn init (ptr: u32) Array {
    return Array{ .id = ptr };
  }

  pub fn new () Array {
    const ptr = jsArrayNew();
    return Array{ .id = ptr };
  }

  pub fn free (self: *const Array) void {
    common.jsFree(self.id);
  }

  pub fn push (self: *const Array, ptr: u32) void {
    jsArrayPush(self.id, ptr);
  }
};
