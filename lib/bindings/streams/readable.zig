const jsFree = @import("../common.zig").jsFree;
const WritableStream = @import("writable.zig").WritableStream;

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1155
pub const ReadableStream = struct {
  id: u32,

  pub fn init (ptr: u32) ReadableStream {
    return ReadableStream{ .id = ptr };
  }

  pub fn free (self: ReadableStream) void {
    jsFree(self.id);
  }

  pub fn bytes() []u8 {

  }

  // pub fn pipeTo(writeable: WritableStream) void {

  // }
};
