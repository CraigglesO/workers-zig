const common = @import("common.zig");
const jsFree = common.jsFree;

// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date
pub const Date = struct {
  id: u32,

  pub fn init (ptr: u32) Date {
    return Date{ .id = ptr };
  }

  pub fn free (self: *const Date) void {
    jsFree(self.id);
  }
};
