// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L345
const jsFree = @import("../bindings/common.zig").jsFree;

// 
pub const DurableObject = struct {
  id: u32,

  pub fn init (ptr: u32) DurableObject {
    return DurableObject{ .id = ptr };
  }

  pub fn free (self: *const DurableObject) void {
    jsFree(self.id);
  }
};
