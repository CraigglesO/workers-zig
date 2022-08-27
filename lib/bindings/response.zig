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
const getStringFree = @import("string.zig").getStringFree;
const ArrayBuffer = @import("arraybuffer.zig").ArrayBuffer;
const FormData = @import("formData.zig").FormData;
const Blob = @import("blob.zig").Blob;
const getObjectValue = @import("object.zig").getObjectValue;
const getObjectValueNum = @import("object.zig").getObjectValueNum;
const WebSocket = @import("../apis/webSocket.zig").WebSocket;
const StatusCode = @import("../http/common.zig").StatusCode;

pub const EncodeBody = enum {
  auto,
  manual,

  pub fn toString (self: *const EncodeBody) []const u8 {
    return switch (self.*) {
      .auto => "auto",
      .manual => "manual"
    };
  }
};

pub const ResponseInit = struct {
  status: ?u16 = null,
  statusText: ?[]const u8 = null,
  headers: ?*const Headers = null,
  webSocket: ?*const WebSocket = null,
  encodeBody: EncodeBody = EncodeBody.auto,

  pub fn toObject (self: *const ResponseInit) Object {
    const obj = Object.new();
    if (self.status != null) obj.setNum("status", @intToFloat(f32, self.status.?));
    if (self.statusText != null) obj.setString("statusText", self.statusText.?);
    if (self.headers != null) obj.set("headers", self.headers.?.id);
    if (self.webSocket != null) obj.set("webSocket", self.webSocket.?.id);
    if (self.encodeBody != EncodeBody.auto) obj.setString("encodeBody", self.encodeBody.toString());

    return obj;
  }
};

// https://developers.cloudflare.com/workers/runtime-apis/response/
// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1461
pub const Response = struct {
  id: u32,

  pub fn init (jsPtr: u32) Response {
    return Response{ .id = jsPtr };
  }

  pub fn free (self: *const Response) void {
    common.jsFree(self.id);
  }
  
  pub fn new (bodyInit: BodyInit, responseInit: ResponseInit) Response {
    // prep arguments
    const jsResOptions = responseInit.toObject();
    defer jsResOptions.free();
    const jsArgs = Array.new();
    defer jsArgs.free();
    const bodyID = bodyInit.toID();
    defer bodyInit.free(bodyID);
    jsArgs.push(bodyID);
    jsArgs.push(jsResOptions.id);
    // create the class
    const jsPtr = common.jsCreateClass(common.Classes.Response.toInt(), jsArgs.id);

    return Response{ .id = jsPtr };
  }

  pub fn fromResponse (bodyInit: BodyInit, response: *const Response) Response {
    // prep arguments
    const jsArgs = Array.new();
    defer jsArgs.free();
    const bodyID = bodyInit.toID();
    defer bodyInit.free(bodyID);
    jsArgs.push(bodyID);
    jsArgs.push(response.id);
    // create the class
    const jsPtr = common.jsCreateClass(common.Classes.Response.toInt(), jsArgs.id);

    return Response{ .id = jsPtr };
  }
  
  // ** CONST **

  pub fn ok (self: *const Response) bool {
    const body = getObjectValue(self.id, "ok");
    defer jsFree(body);
    return body == True;
  }

  pub fn status (self: *const Response) StatusCode {
    const code = getObjectValueNum(self.id, "status");
    return StatusCode.fromInt(code);
  }

  // NOTE: the returned string is a pointer to a string in memory that must be freed
  pub fn statusText (self: *const Response) []const u8 {
    const methodStr = String.init(getObjectValue(self.id, "statusText"));
    defer methodStr.free();
    return methodStr.value();
  }

  pub fn webSocket (self: *const Response) ?WebSocket {
    const value = getObjectValue(self.id, "webSocket");
    if (value == Null) return null;
    return WebSocket.init(value);
  }

  pub fn method (self: *const Response) Method {
    // grab the method var
    const methodStr = String.init(getObjectValue(self.id, "method"));
    defer methodStr.free();
    const str = methodStr.value();
    defer allocator.free(str);
    // return the method
    return Method.fromString(str);
  }

  // NOTE: the returned string is a pointer to a string in memory that must be freed
  pub fn url (self: *const Response) []const u8 {
    // grab the url var
    const urlStr = String.init(getObjectValue(self.id, "url"));
    defer urlStr.free();
    // return the url
    return urlStr.value();
  }

  pub fn headers (self: *const Response) Headers {
    return Headers.init(getObjectValue(self.id, "headers"));
  }

  // "follow", "error", or "manual"
  pub fn redirected (self: *const Response) bool {
    const body = getObjectValue(self.id, "redirected");
    defer jsFree(body);
    return body == True;
  }

  // ** FUNCTIONS **

  pub fn redirect(self: *const Response, newURL: []const u8, newStatus: ?u16) Response {
    // grab the redirect function
    const func = Function{ .id = getObjectValue(self.id, "redirect") };
    defer func.free();
    // add arguments
    const args = Array.new();
    defer args.free();
    // build string
    const urlStr = String.new(newURL);
    defer urlStr.free();
    args.push(urlStr.id);
    args.push(newStatus orelse Undefined);
    // call the clone function and return the resultant pointer
    return Response.init(func.callArgs(args));
  }

  pub fn clone (self: *const Response) Response {
    // grab the clone function
    const func = Function{ .id = getObjectValue(self.id, "clone") };
    defer func.free();
    // call the clone function and return the resultant pointer
    return Response.init(func.call());
  }

  // ** BODY **
  // body is ReadableStream | null

  // check that body is ReadableStream
  pub fn hasBody (self: *const Response) bool {
    const body = getObjectValue(self.id, "body");
    defer jsFree(body);
    return body != Null;
  }

  pub fn bodyUsed (self: *const Response) bool {
    const bUsed = getObjectValue(self.id, "bodyUsed");
    defer jsFree(bUsed);
    return bUsed == True;
  }

  pub fn arrayBuffer (self: *const Response) ?ArrayBuffer {
    if (!self.hasBody()) return null;
    const aFunc = AsyncFunction.init(getObjectValue(self.id, "arrayBuffer"));
    defer aFunc.free();
    const abID = aFunc.call();
    return ArrayBuffer.init(abID);
  }

  // NOTE: the returned string is a pointer to a string in memory that must be freed
  pub fn text (self: *const Response) ?[]const u8 {
    if (!self.hasBody()) return null;
    const aFunc = AsyncFunction.init(getObjectValue(self.id, "text"));
    defer aFunc.free();
    const strPtr = aFunc.call();
    if (strPtr <= DefaultValueSize) return;
    return getStringFree(strPtr);
  }

  pub fn json (self: *const Response, comptime T: type) ?T {
    if (!self.hasBody()) return null;
    // get the "string" and then parse it locally
    const str = self.text();
    defer allocator.free(str);
    const stream = std.json.TokenStream.init(str);
    return try std.json.parse(T, &stream, .{});
  }

  pub fn formData (self: *const Response) ?FormData {
    if (!self.hasBody()) return null;
    const aFunc = AsyncFunction.init(getObjectValue(self.id, "formData"));
    defer aFunc.free();
    const formID = aFunc.call();
    return FormData.init(formID);
  }

  pub fn blob (self: *const Response) ?Blob {
    if (!self.hasBody()) return null;
    const aFunc = AsyncFunction.init(getObjectValue(self.id, "blob"));
    defer aFunc.free();
    const blobID = aFunc.call();
    return Blob.init(blobID);
  }

  // fast track arrayBuffer->toOwned
  pub fn bytes (self: *const Response) ?[]u8 {
    if (!self.hasBody()) return null;
    const ab = self.arrayBuffer();
    defer ab.free();
    return ab.bytes();
  }
};
