const common = @import("../bindings/common.zig");
const Undefined = common.Undefined;
const True = common.True;
const toJSBool = common.toJSBool;
const jsFree = common.jsFree;
const String = @import("../bindings/string.zig").String;
const Request = @import("../bindings/request.zig").Request;
const RequestInfo = @import("../bindings/request.zig").RequestInfo;
const Response = @import("../bindings/response.zig").Response;
const AsyncFunction = @import("../bindings/function.zig").AsyncFunction;
const Array = @import("../bindings/array.zig").Array;
const Object = @import("../bindings/object.zig").Object;
const getObjectValue = @import("../bindings/object.zig").getObjectValue;

pub extern fn jsCacheGet(frame: *anyopaque, keyPtr: u32, resPtr: *u32) void;
pub fn getCache(keyPtr: u32) u32 {
  var res: u32 = 0;
  suspend {
    jsCacheGet(@frame(), keyPtr, &res);      
  }
  return res;
}

pub const CacheOptions = union(enum) {
  text: []const u8,
  string: *const String,
  none,

  pub fn toID (self: *const CacheOptions) u32 {
    switch (self.*) {
      .text => |t| return String.new(t).id,
      .string => |s| return s.id,
      .none => return Undefined,
    }
  }

  pub fn free (self: *const CacheOptions, id: u32) void {
    switch (self.*) {
      .text => jsFree(id),
      else => {},
    }
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L149
pub const CacheQueryOptions = struct {
  ignoreMethod: ?bool = null,

  pub fn toObject (self: *const CacheQueryOptions) Object {
    const obj = Object.new();
    if (self.ignoreMethod != null) obj.setID("ignoreMethod", toJSBool(self.ignoreMethod.?));
    return obj;
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L137
pub const Cache = struct {
  id: u32,

  pub fn init (ptr: u32) Cache {
    return Cache{ .id = ptr };
  }

  pub fn new (options: CacheOptions) Cache {
    const optsPtr = options.toID();
    defer options.free(optsPtr);
    return Cache{ .id = getCache(optsPtr) };
  }

  pub fn free (self: *const Cache) void {
    jsFree(self.id);
  }

  pub fn put (
    self: *const Cache,
    req: RequestInfo,
    res: *const Response
  ) void {
    // prep arguments
    const reqID = req.toID();
    defer req.free(reqID);
    const arr = Array.new();
    defer arr.free();
    arr.pushID(reqID);
    arr.push(res);
    // build async function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "put") };
    defer func.free();
    // call async function
    _ = func.callArgsID(arr.id);
  }

  pub fn match (
    self: *const Cache,
    req: RequestInfo,
    options: CacheQueryOptions
  ) ?Response {
    // prep arguments
    const reqID = req.toID();
    defer req.free(reqID);
    const opts = options.toObject();
    defer opts.free();
    const arr = Array.new();
    defer arr.free();
    arr.pushID(reqID);
    arr.push(&opts);
    // build async function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "match") };
    defer func.free();
    // call async function
    const result = func.callArgsID(arr.id);
    if (result == Undefined) return null;
    return Response{ .id = result };
  }

  pub fn delete (
    self: *const Cache,
    req: RequestInfo,
    options: CacheQueryOptions
  ) bool {
    // prep arguments
    const reqID = req.toID();
    defer req.free(reqID);
    const opts = options.toObject();
    defer opts.free();
    const arr = Array.new();
    defer arr.free();
    arr.pushID(reqID);
    arr.push(&opts);
    // build async function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "delete") };
    defer func.free();
    // call async function
    const result = func.callArgsID(arr.id);
    return result == True;
  }
};
