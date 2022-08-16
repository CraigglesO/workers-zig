const jsFree = @import("../bindings/common.zig").jsFree;

// 
pub const Crypto = struct {
  id: u32,

  pub fn init (ptr: u32) Crypto {
    return Crypto{ .id = ptr };
  }

  pub fn free (self: *const Crypto) void {
    jsFree(self.id);
  }
};
