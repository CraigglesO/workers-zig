const std = @import("std");
const mem = std.mem;
const allocator = std.heap.page_allocator;
const common = @import("common.zig");
const jsFree = common.jsFree;
const Null = common.Null;
const True = common.True;
const Undefined = common.Undefined;
const BodyInit = @import("body.zig").BodyInit;
const Function = @import("function.zig").Function;
const AsyncFunction = @import("function.zig").AsyncFunction;
const Cf = @import("cf.zig");
const Headers = @import("headers.zig").Headers;
const Method = @import("../http/common.zig").Method;
const Object = @import("object.zig").Object;
const String = @import("string.zig").String;
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
  method: ?Method = null,
  headers: ?Headers = null,
  body: ?BodyInit = null,
  redirect: ?Redirect = null,
  cf: ?Cf.CfRequestInit = null,

  pub fn toObject (self: *const RequestInit) Object {
    const obj = Object.new();
    if (self.method != null) obj.setString("method", self.method.?.toString());
    if (self.headers != null) obj.set("headers", self.headers.?.id);
    var bodyID: u32 = Undefined;
    if (self.body != null) {
      switch (self.body.?) {
        .readableStream => |*rs| bodyID = rs.id,
        .string => |*s| bodyID = s.id,
        .arrayBuffer => |*ab| bodyID = ab.id,
        .blob => |*blob| bodyID = blob.id,
        .urlSearchParams => |*usp| bodyID = usp.id,
        .formData => |*fd| bodyID = fd.id,
        .none => {},
      }
    }
    if (bodyID != Undefined) obj.set("body", bodyID);
    if (self.redirect != null) obj.setString("redirect", self.redirect.?.toString());
    var cfID: u32 = Undefined;
    if (self.cf != null) {
      switch (self.cf.?) {
        .incomingRequestCfProperties => |*crp| cfID = crp.id,
        .requestInitCfProperties => |*rip| cfID = rip.id,
        .none => {},
      }
    }
    if (cfID != Undefined) obj.set("cf", cfID);

    return obj;
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

  // TODO:
  // pub fn new (requestStr: []const u8 | Request, requestInit: RequestInit | Request | Undefined) Request {

  // }

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

  pub fn method (self: *const Request) !Method {
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

  pub fn cf (self: *const Request) !Cf.IncomingRequestCfProperties {
    return Cf.IncomingRequestCfProperties.init(self);
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
    if (!self.hasBody()) return undefined;
    const aFunc = AsyncFunction.init(getObjectValue(self.id, "arrayBuffer"));
    defer aFunc.free();
    const abID = await async aFunc.call();
    return ArrayBuffer.init(abID);
  }

  // NOTE: the returned string is a pointer to a string in memory that must be freed
  pub fn text (self: *const Request) callconv(.Async) ?[]const u8 {
    if (!self.hasBody()) return undefined;
    const aFunc = AsyncFunction.init(getObjectValue(self.id, "text"));
    defer aFunc.free();
    return await async getString(aFunc.call(Undefined));
  }

  pub fn json (self: *const Request, comptime T: type) callconv(.Async) ?T {
    if (!self.hasBody()) return undefined;
    // get the "string" and then parse it locally
    const str = await async self.text();
    defer allocator.free(str);
    const stream = std.json.TokenStream.init(str);
    return try std.json.parse(T, &stream, .{});
  }

  pub fn formData (self: *const Request) callconv(.Async) ?FormData {
    if (!self.hasBody()) return undefined;
    const aFunc = AsyncFunction.init(getObjectValue(self.id, "formData"));
    defer aFunc.free();
    const formID = await async aFunc.call();
    return FormData.init(formID);
  }

  pub fn blob (self: *const Request) callconv(.Async) ?Blob {
    if (!self.hasBody()) return undefined;
    const aFunc = AsyncFunction.init(getObjectValue(self.id, "blob"));
    defer aFunc.free();
    const blobID = await async aFunc.call();
    return Blob.init(blobID);
  }

  // fast track arrayBuffer->toOwned
  pub fn bytes (self: *const Request) callconv(.Async) ?[]u8 {
    if (!self.hasBody()) return undefined;
    const ab = await async self.arrayBuffer();
    defer ab.free();
    return ab.bytes();
  }
};
