const common = @import("../common.zig");
const jsFree = common.jsFree;
const jsCreateClass = common.jsCreateClass;
const Classes = common.Classes;
const Undefined = common.Undefined;
const object = @import("../object.zig");
const getObjectValue = object.getObjectValue;
const ReadableStream = @import("readable.zig").ReadableStream;
const WritableStream = @import("writable.zig").WritableStream;

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1733
pub const TransformStream = struct {
  id: u32,

  pub fn init (ptr: u32) TransformStream {
    return TransformStream{ .id = ptr };
  }

  // TODO: Supprt inputs
  pub fn new () TransformStream {
    return TransformStream{ .id = jsCreateClass(Classes.TransformStream.toInt(), Undefined) };
  }

  pub fn free (self: TransformStream) void {
    jsFree(self.id);
  }

  pub fn readable (self: *const TransformStream) ReadableStream {
    return ReadableStream{ .id = getObjectValue(self.id, "readable") };
  }

  pub fn writable (self: *const TransformStream) WritableStream {
    return WritableStream{ .id = getObjectValue(self.id, "writable") };
  }
};
