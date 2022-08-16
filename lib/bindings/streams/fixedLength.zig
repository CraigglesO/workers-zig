const jsFree = @import("../common.zig").jsFree;

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L651
pub const FixedLengthStream = struct {
  id: u32,

  pub fn init (ptr: u32) FixedLengthStream {
    return FixedLengthStream{ .id = ptr };
  }

  pub fn free (self: FixedLengthStream) void {
    jsFree(self.id);
  }
};
