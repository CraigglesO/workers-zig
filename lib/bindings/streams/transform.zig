const jsFree = @import("../common.zig").jsFree;

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1733
pub const TransformStream = struct {
  id: u32,

  pub fn init (ptr: u32) TransformStream {
    return TransformStream{ .id = ptr };
  }

  pub fn free (self: TransformStream) void {
    jsFree(self.id);
  }
};
