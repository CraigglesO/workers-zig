const std = @import("std");
const allocator = std.heap.page_allocator;
const common = @import("common.zig");
const jsFree = common.jsFree;
const getStringClean = @import("string.zig").getStringClean;
const object = @import("object.zig");
const getObjectValue = object.getObjectValue;
const hasObject = object.hasObject;

pub const Record = struct {
  id: u32,

  pub fn init (ptr: u32) Record {
    return Record{ .id = ptr };
  }

  // TODO: pub fn keys ()
  // TODO: pub fn values ()
  // TODO: pub fn entries ()

  pub fn free (self: *const Record) void {
    jsFree(self.id);
  }

  pub fn has (self: *const Record, key: []const u8) bool {
    return hasObject(self.id, key);
  }

  pub fn get (self: *const Record, key: []const u8) []const u8 {
    return getStringClean(getObjectValue(self.id, key));
  }
};
