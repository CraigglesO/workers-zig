const jsFree = @import("../bindings/common.zig").jsFree;

// 
pub const D1 = struct {
  id: u32,

  pub fn init (ptr: u32) D1 {
    return D1{ .id = ptr };
  }

  pub fn free (self: *const D1) void {
    jsFree(self.id);
  }
};
