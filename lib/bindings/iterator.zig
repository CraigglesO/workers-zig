const jsFree = @import("common.zig").jsFree;

pub const Iterator = struct {
  id: u32,

  pub fn init (ptr: u32) Iterator {
    return Iterator{ .id = ptr };
  }

  pub fn free (self: *const Iterator) void {
    jsFree(self.id);
  }

  // pub fn next () {

  // }
};