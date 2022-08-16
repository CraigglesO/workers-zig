const jsFree = @import("../common.zig").jsFree;

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L326
pub const DecompressionStream = struct {
  id: u32,

  pub fn init (ptr: u32) DecompressionStream {
    return DecompressionStream{ .id = ptr };
  }

  pub fn free (self: DecompressionStream) void {
    jsFree(self.id);
  }
};
