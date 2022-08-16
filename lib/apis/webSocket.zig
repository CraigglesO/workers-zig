const jsFree = @import("../bindings/common.zig").jsFree;

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1881
pub const WebSocket = struct {
  id: u32,

  pub fn init (ptr: u32) WebSocket {
    return WebSocket{ .id = ptr };
  }

  pub fn free (self: *const WebSocket) void {
    jsFree(self.id);
  }
};
