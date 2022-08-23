const std = @import("std");
const mem = std.mem;
const allocator = std.heap.page_allocator;
const common = @import("common.zig");
const jsFree = common.jsFree;
const Null = common.Null;
const True = common.True;
const Undefined = common.Undefined;
const Classes = common.Classes;
const DefaultValueSize = common.DefaultValueSize;
const jsCreateClass = common.jsCreateClass;
const BodyInit = @import("body.zig").BodyInit;
const Function = @import("function.zig").Function;
const AsyncFunction = @import("function.zig").AsyncFunction;
const Cf = @import("cf.zig");
const Headers = @import("headers.zig").Headers;
const Method = @import("../http/common.zig").Method;
const Object = @import("object.zig").Object;
const String = @import("string.zig").String;
const Array = @import("array.zig").Array;
const getString = @import("string.zig").getString;
const ArrayBuffer = @import("arraybuffer.zig").ArrayBuffer;
const FormData = @import("formdata.zig").FormData;
const Blob = @import("blob.zig").Blob;
const getObjectValue = @import("object.zig").getObjectValue;

pub const Redirect = enum {
  Follow,
  Error,
  Manual,

  const redirects = [_][]const u8 {
    "follow",
    "error",
    "manual",
  };

  pub fn toString(self: *const Redirect) []const u8 {
    return redirects[@enumToInt(self)];
  }

  pub fn fromString(str: []const u8) !Redirect {
    for (redirects) |v, i| {
      if (mem.eql(u8, v, str)) {
        return @intToEnum(Redirect, @truncate(u3, i));
      }
    }
    return error.Unsupported;
  }
};

// https://developers.cloudflare.com/workers/runtime-apis/request#requestinit
// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1260
pub const RequestInit = struct {
  body: ?BodyInit = null, // can be empty
  method: ?Method = null,
  headers: ?Headers = null,
  redirect: ?Redirect = null,
  cf: ?Cf.CfRequestInit = null,

  pub fn toObject (self: *const RequestInit) Object {
    const obj = Object.new();
    if (self.body != null) {
      const bodyID = self.body.?.getID();
      if (bodyID != Null) obj.set("body", bodyID);
    }
    if (self.method != null) obj.setString("method", self.method.?.toString());
    if (self.headers != null) obj.set("headers", self.headers.?.id);
    if (self.redirect != null) obj.setString("redirect", self.redirect.?.toString());
    if (self.cf != null) {
      const cfID = self.cf.?.getID();
      if (cfID != Null) obj.set("cf", cfID);
    }

    return obj;
  }
};

pub const RequestInfo = union(enum) {
  string: []const u8,
  jsString: *const String,
  request: *const Request,

  // NOTE: Since the option may be a string, be sure to `jsFree(id)`
  pub fn toID (self: *const RequestInfo) u32 {
    var requestPtr: u32 = Undefined;
    switch (self.*) {
      .string => |str| {
        const jsString = String.new(str);
        requestPtr = jsString.id;
      },
      .jsString => |jsString| {
        requestPtr = jsString.id;
      },
      .request => |req| requestPtr = req.id,
    }
    return requestPtr;
  }
};

pub const RequestOptions = union(enum) {
  requestInit: *const RequestInit,
  request: *const Request,
  none,

  pub fn toID(self: *const RequestOptions) u32 {
    var reqInitID: u32 = Undefined;
    switch (self.*) {
      .requestInit => |ri| reqInitID = ri.id,
      .request => |req| reqInitID = req.id,
      .none => {},
    }
    return reqInitID;
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1248
pub const Request = struct {
  // where in memory this Object is located
  id: u32,

  // ** BUILD **

  pub fn init (ptr: u32) Request {
    return Request{ .id = ptr };
  }

  pub fn new (requestStr: RequestInfo, requestInit: RequestOptions) Request {
    // prepare arguments
    const reqID = requestStr.toID();
    defer jsFree(reqID);
    const reqInitID = requestInit.toID();
    defer jsFree(reqInitID);

    // setup arg array
    const args = Array.new();
    defer args.free();
    args.push(reqID);
    args.push(reqInitID);
    
    return Request{ .id = jsCreateClass(Classes.Request.toInt(), args.id) };
  }

  pub fn free (self: *const Request) void {
    jsFree(self.id);
  }

  pub fn clone (self: *const Request) Request {
    // grab the clone function
    const func = Function{ .id = getObjectValue(self.id, "clone") };
    defer func.free();
    // call the clone function and return the resultant pointer
    return Request.init(func.call());
  }

  // ** VARS **

  pub fn method (self: *const Request) Method {
    // grab the method var
    const methodStr = String.init(getObjectValue(self.id, "method"));
    defer methodStr.free();
    const str = methodStr.value();
    defer allocator.free(str);
    // return the method
    return Method.fromString(str);
  }

  // NOTE: the returned string is a pointer to a string in memory that must be freed
  // var str = Request.url();
  // defer allocator.free(str);
  pub fn url (self: *const Request) []const u8 {
    // grab the url var
    const urlStr = String.init(getObjectValue(self.id, "url"));
    defer urlStr.free();
    // return the url
    return urlStr.value();
  }

  pub fn headers (self: *const Request) Headers {
    return Headers.init(getObjectValue(self.id, "headers"));
  }

  // "follow", "error", or "manual"
  pub fn redirect (self: *const Request) !Redirect {
    return Redirect.fromString(getObjectValue(self.id, "redirect"));
  }

  pub fn cf (self: *const Request) Cf.IncomingRequestCfProperties {
    return Cf.IncomingRequestCfProperties.init(getObjectValue(self.id, "cf"));
  }

  // ** BODY **
  // body is ReadableStream | null

  // check that body is ReadableStream
  pub fn hasBody (self: *const Request) bool {
    const body = getObjectValue(self.id, "body");
    defer jsFree(body);
    return body != Null;
  }

  pub fn bodyUsed (self: *const Request) bool {
    const bUsed = getObjectValue(self.id, "bodyUsed");
    return bUsed == True;
  }

  pub fn arrayBuffer (self: *const Request) callconv(.Async) ?ArrayBuffer {
    if (!self.hasBody()) return null;
    const aFunc = AsyncFunction.init(getObjectValue(self.id, "arrayBuffer"));
    defer aFunc.free();
    return ArrayBuffer.init(await async aFunc.call());
  }

  // NOTE: the returned string is a pointer to a string in memory that must be freed
  pub fn text (self: *const Request) callconv(.Async) ?[]const u8 {
    if (!self.hasBody()) return null;
    const aFunc = AsyncFunction.init(getObjectValue(self.id, "text"));
    defer aFunc.free();
    const strPtr = aFunc.call();
    if (strPtr <= DefaultValueSize) return null;
    defer jsFree(strPtr);
    return await async getString(strPtr);
  }

  pub fn json (self: *const Request, comptime T: type) callconv(.Async) ?T {
    if (!self.hasBody()) return null;
    // get the "string" and then parse it locally
    const str = await async self.text();
    defer allocator.free(str);
    const stream = std.json.TokenStream.init(str);
    return try std.json.parse(T, &stream, .{});
  }

  pub fn formData (self: *const Request) callconv(.Async) ?FormData {
    if (!self.hasBody()) return null;
    const aFunc = AsyncFunction.init(getObjectValue(self.id, "formData"));
    defer aFunc.free();
    return FormData.init(await async aFunc.call());
  }

  pub fn blob (self: *const Request) callconv(.Async) ?Blob {
    if (!self.hasBody()) return null;
    const aFunc = AsyncFunction.init(getObjectValue(self.id, "blob"));
    defer aFunc.free();
    return Blob.init(await async aFunc.call());
  }

  // fast track arrayBuffer->toOwned
  pub fn bytes (self: *const Request) callconv(.Async) ?[]u8 {
    if (!self.hasBody()) return null;
    const ab = await async self.arrayBuffer();
    defer ab.free();
    return ab.bytes();
  }
};
