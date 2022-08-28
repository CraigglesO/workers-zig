const common = @import("common.zig");
const jsFree = common.jsFree;
const jsSize = common.jsSize;
const jsToBytes = common.jsToBytes;
const jsToBuffer = common.jsToBuffer;
const JSValue = common.JSValue;
const Classes = common.Classes;
const jsCreateClass = common.jsCreateClass;

pub const ArrayBuffer = struct {
  id: u32,

  pub fn init (ptr: u32) ArrayBuffer {
    return ArrayBuffer{ .id = ptr };
  }

  pub fn new (data: []const u8) ArrayBuffer {
    return ArrayBuffer{ .id = jsToBuffer(data.ptr, data.len) };
  }

  pub fn free (self: *const ArrayBuffer) void {
    jsFree(self.id);
  }

  // NOTE: be sure to free the bytes after use
  pub fn bytes (self: *const ArrayBuffer) []const u8 {
    // first get the size
    const size = jsSize(self.id);
    // get the bytes
    const data = jsToBytes(self.id);
    // create a slice
    return data[0..size];
  }

  pub fn uint8Array (self: *const ArrayBuffer) JSValue {
    return JSValue.init(jsCreateClass(Classes.Uint8Array.toInt(), self.id));
  }

  pub fn byteLength (self: *const ArrayBuffer) u32 {
    return jsSize(self.id);
  }
};