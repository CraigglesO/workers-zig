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

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1903
pub const WebSocketPair = struct {
  id: u32,

  pub fn init (ptr: u32) WebSocketPair {
    return WebSocketPair{ .id = ptr };
  }

  pub fn free (self: *const WebSocketPair) void {
    jsFree(self.id);
  }
};
