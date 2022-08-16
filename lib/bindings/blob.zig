const jsFree = @import("common.zig").jsFree;

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L91
pub const Blob = struct {
  id: u32,

  pub fn init (ptr: u32) Blob {
    return Blob{ .id = ptr };
  }

  pub fn free (self: *const Blob) void {
    jsFree(self.id);
  }
};