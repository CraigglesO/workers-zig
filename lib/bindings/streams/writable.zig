const common = @import("../common.zig");
const jsFree = common.jsFree;
const jsCreateClass = common.jsCreateClass;
const Classes = common.Classes;
const Undefined = common.Undefined;
const True = common.True;
const object = @import("../object.zig");
const Object = object.Object;
const getObjectValue = object.getObjectValue;
const AsyncFunction = @import("../function.zig").AsyncFunction;

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1914
pub const WritableStream = struct {
  id: u32,

  pub fn init (ptr: u32) WritableStream {
    return WritableStream{ .id = ptr };
  }

  // TODO: Supprt inputs
  pub fn new () WritableStream {
    return WritableStream{ .id = jsCreateClass(Classes.WritableStream.toInt(), Undefined) };
  }

  pub fn free (self: WritableStream) void {
    jsFree(self.id);
  }

  pub fn locked (self: *const WritableStream) bool {
    const jsPtr = getObjectValue(self.id, "locked");
    return jsPtr == True;
  }

  pub fn abort (self: *const WritableStream) void {
    const func = AsyncFunction{ .id = getObjectValue(self.id, "abort") };
    defer func.free();
    func.call();
  }

  pub fn close (self: *const WritableStream) void {
    const func = AsyncFunction{ .id = getObjectValue(self.id, "close") };
    defer func.free();
    func.call();
  }
};
