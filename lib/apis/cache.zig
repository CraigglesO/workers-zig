const common = @import("../bindings/common.zig");
const Undefined = common.Undefined;
const True = common.True;
const False = common.False;
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
  string: []const u8,
  none,

  pub fn toID (self: *const CacheOptions) u32 {
    var key: u32 = Undefined;
    switch (self.*) {
      .string => |str| {
        const string = String.new(str);
        key = string.id;
      },
      .none => {},
    }

    return key;
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L149
pub const CacheQueryOptions = struct {
  ignoreMethod: ?bool = null,

  pub fn toObject (self: *const CacheQueryOptions) Object {
    const obj = Object.new();
    if (self.ignoreMethod != null) {
      var ignoreID = False;
      if (self.ignoreMethod.? == true) ignoreID = True;
      obj.set("ignoreMethod", ignoreID);
    }
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
    const key = options.toID();
    defer jsFree(key);
    return Cache{ .id = getCache(key) };
  }

  pub fn free (self: *const Cache) void {
    jsFree(self.id);
  }

  pub fn delete (
    self: *const Cache,
    request: RequestInfo,
    options: *const CacheQueryOptions
  ) bool {
    // prep arguments
    const reqID = request.toID();
    defer jsFree(reqID);
    const opts = options.toObject();
    defer jsFree(opts);
    const arr = Array.new();
    arr.push(reqID);
    arr.push(opts);
    // build async function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "delete") };
    defer func.free();
    // call async function
    const result = func.callArgs(arr.id);
    return result == True;
  }

  pub fn match (
    self: *const Cache,
    request: RequestInfo,
    options: *const CacheQueryOptions
  ) ?Response {
    // prep arguments
    const reqID = request.toID();
    defer jsFree(reqID);
    const opts = options.toObject();
    defer jsFree(opts);
    const arr = Array.new();
    arr.push(reqID);
    arr.push(opts);
    // build async function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "match") };
    defer func.free();
    // call async function
    const result = func.callArgs(arr.id);
    if (result == Undefined) {
      return;
    }
    return Response{ .id = result };
  }

  pub fn put (
    self: *const Cache,
    request: RequestInfo,
    response: *const Response
  ) void {
    // prep arguments
    const reqID = request.toID();
    defer jsFree(reqID);
    const resID = response.toID();
    defer jsFree(resID);
    const arr = Array.new();
    arr.push(reqID);
    arr.push(resID);
    // build async function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "put") };
    defer func.free();
    // call async function
    func.callArgs(arr.id);
  }
};
