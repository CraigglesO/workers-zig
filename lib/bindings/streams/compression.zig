const jsFree = @import("../common.zig").jsFree;

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L196
pub const CompressionStream = struct {
  id: u32,

  pub fn init (ptr: u32) CompressionStream {
    return CompressionStream{ .id = ptr };
  }

  pub fn free (self: CompressionStream) void {
    jsFree(self.id);
  }
};
