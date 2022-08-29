const common = @import("../common.zig");
const jsFree = common.jsFree;
const jsCreateClass = common.jsCreateClass;
const Classes = common.Classes;
const toJSBool = common.toJSBool;
const Undefined = common.Undefined;
const True = common.True;
const object = @import("../object.zig");
const Object = object.Object;
const getObjectValue = object.getObjectValue;
const AsyncFunction = @import("../function.zig").AsyncFunction;
const WritableStream = @import("writable.zig").WritableStream;
const Array = @import("../array.zig").Array;

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L989
pub const PipeToOptions = struct {
  preventClose: ?bool = null,
  preventAbort: ?bool = null,
  preventCancel: ?bool = null,
  // NOTE: This exists but will prob never be implemented.
  // signal: ?AbortSignal = null,

  pub fn toObject (self: *const PipeToOptions) Object {
    const obj = Object.new();
    if (self.preventClose != null) {
      obj.setID("ignoreMethod", toJSBool(self.preventClose.?));
    }
    // if (self.preventAbort != null) { obj.setID("ignoreMethod", toJSBool(self.preventAbort.?)); }
    // if (self.preventCancel != null) { obj.setID("ignoreMethod", toJSBool(self.preventCancel.?)); }
    return obj;
  }
};

// TODO: Plenty of functions/structs not implemented here yet.
// https://developers.cloudflare.com/workers/runtime-apis/streams/readablestream/
// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1155
pub const ReadableStream = struct {
  id: u32,

  pub fn init (ptr: u32) ReadableStream {
    return ReadableStream{ .id = ptr };
  }

  // TODO: Support inputs
  pub fn new () ReadableStream {
    return ReadableStream{ .id = jsCreateClass(Classes.ReadableStream.toInt(), Undefined) };
  }

  pub fn free (self: ReadableStream) void {
    jsFree(self.id);
  }

  pub fn locked (self: *const ReadableStream) bool {
    const jsPtr = getObjectValue(self.id, "locked");
    return jsPtr == True;
  }

  pub fn cancel (self: *const ReadableStream) void {
    const func = AsyncFunction{ .id = getObjectValue(self.id, "cancel") };
    defer func.free();
    func.call();
  }

  pub fn pipeTo (
    self: *const ReadableStream,
    destination: *const WritableStream,
    options: PipeToOptions
  ) void {
    const optObj = options.toObject();
    defer optObj.free();
    const func = AsyncFunction{ .id = getObjectValue(self.id, "pipeTo") };
    defer func.free();

    // setup args
    const args = Array.new();
    defer args.free();
    args.push(&destination);
    args.push(&optObj);

    func.call(args.id);
  }
};
