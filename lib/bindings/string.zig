const std = @import("std");
const allocator = std.heap.page_allocator;
const common = @import("common.zig");
const jsFree = common.jsFree;
const jsLog = common.jsLog;

pub extern fn jsStringSet (ptr: [*]const u8, len: u32) u32;
pub extern fn jsStringGet (ptr: u32) [*:0]const u8;
pub extern fn jsStringThrow (ptr: u32) void;
// NOTE: the returned string is a pointer to a string in memory that must be freed
pub fn getString (jsPtr: u32) []const u8 {
  const ptr = jsStringGet(jsPtr);
  return std.mem.span(ptr);
}
pub fn getStringFree (jsPtr: u32) []const u8 {
  const ptr = jsStringGet(jsPtr);
  defer jsFree(jsPtr);
  return std.mem.span(ptr);
}

pub const String = struct {
  id: u32,

  pub fn init (ptr: u32) String {
    return String{ .id = ptr };
  }

  pub fn new (str: []const u8) String {
    const ptr = jsStringSet(str.ptr, str.len);
    return String{ .id = ptr };
  }

  pub fn free (self: *const String) void {
    jsFree(self.id);
  }

  // NOTE: the returned string is a pointer to a string in memory that must be freed
  pub fn value (self: *const String) []const u8 {
    return getString(self.id);
  }

  pub fn log (self: *const String) void {
    jsLog(self.id);
  }

  pub fn throw (self: *const String) void {
    jsStringThrow(self.id);
  }
};
