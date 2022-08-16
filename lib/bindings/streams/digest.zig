const jsFree = @import("../common.zig").jsFree;

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L330
pub const DigestStream = struct {
  id: u32,

  pub fn init (ptr: u32) DigestStream {
    return DigestStream{ .id = ptr };
  }

  pub fn free (self: DigestStream) void {
    jsFree(self.id);
  }
};
