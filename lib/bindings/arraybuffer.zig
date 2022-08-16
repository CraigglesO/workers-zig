const common = @import("common.zig");
const jsFree = common.jsFree;
const jsSize = common.jsSize;
const jsToBytes = common.jsToBytes;

pub const ArrayBuffer = struct {
  id: u32,

  pub fn init (ptr: u32) ArrayBuffer {
    return ArrayBuffer{ .id = ptr };
  }

  pub fn free (self: *const ArrayBuffer) void {
    jsFree(self.id);
  }

  // NOTE: be sure to free the bytes after use
  pub fn bytes (self: *const ArrayBuffer) []u8 {
    // first get the size
    const size = jsSize(self.id);
    // get the bytes
    const data = jsToBytes(self.id);
    // create a slice
    return data[0..size];
  }
};