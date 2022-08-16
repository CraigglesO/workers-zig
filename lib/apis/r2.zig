const jsFree = @import("../bindings/common.zig").jsFree;

// 
pub const R2 = struct {
  id: u32,

  pub fn init (ptr: u32) R2 {
    return R2{ .id = ptr };
  }

  pub fn free (self: *const R2) void {
    jsFree(self.id);
  }
};
