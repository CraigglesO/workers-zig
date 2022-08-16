const jsFree = @import("../bindings/common.zig").jsFree;

// 
pub const Cache = struct {
  id: u32,

  pub fn init (ptr: u32) Cache {
    return Cache{ .id = ptr };
  }

  pub fn free (self: *const Cache) void {
    jsFree(self.id);
  }
};
