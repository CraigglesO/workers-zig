const common = @import("common.zig");
const Null = common.Null;
const BodyInit = @import("body.zig").BodyInit;
const Array = @import("array.zig").Array;
const Headers = @import("headers.zig").Headers;
const Object = @import("object.zig").Object;
const WebSocket = @import("../apis/websocket.zig").WebSocket;

// https://developers.cloudflare.com/workers/runtime-apis/response/
// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1461

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

pub const Response = struct {
  id: u32,

  pub fn init (jsPtr: u32) Response {
    return Response{ .id = jsPtr };
  }

  pub fn free (self: *const Response) void {
    common.jsFree(self.id);
  }
  
  // TODO:
  pub fn new (bodyInit: BodyInit, responseInit: ResponseInit) Response {
    // prep arguments
    const jsResOptions = responseInit.toObject();
    defer jsResOptions.free();
    const jsArgs = Array.new();
    defer jsArgs.free();
    var bodyID: u32 = Null;
    switch (bodyInit) {
      .readableStream => |rs| bodyID = rs.id,
      .string => |s| bodyID = s.id,
      .arrayBuffer => |ab| bodyID = ab.id,
      .blob => |blob| bodyID = blob.id,
      .urlSearchParams => |params| bodyID = params.id,
      .formData => |formData| bodyID = formData.id,
      .none => {},
    }
    jsArgs.push(bodyID);
    jsArgs.push(jsResOptions.id);
    // create the class
    const jsPtr = common.jsCreateClass(common.Classes.Response.toInt(), jsArgs.id);

    return Response{ .id = jsPtr };
  }

  // pub fn fromString (string: []const u8, responseInit: ?ResponseInit) *Response {

  // }

  // pub fn fromBytes (bytes: []u8, responseInit: ?ResponseInit) *Response {

  // }

  // pub fn fromResponse(body: ?Body, response: Response) *Response {

  // }
  

  // CONST

  // pub fn body () ?Body {

  // }

  // pub fn ok () bool {

  // }

  // pub fn status () u16 {

  // }

  // pub fn statusText () []u8 {

  // }

  // pub fn headers () Headers {

  // }

  // pub fn url () []u8 {

  // }

  // pub fn redirected () bool {

  // }

  // pub fn webSocket () ?WebSocket {

  // }

  // FUNCTIONS

  // pub fn redirect(url: []u8, status: ?u16) *Response {

  // }

  // fn clone() *Response {

  // }
};
