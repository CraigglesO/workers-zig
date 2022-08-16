pub extern fn jsFree (ptr: u32) void;
pub extern fn jsSize (ptr: u32) u32;
pub extern fn jsToBytes (ptr: u32) [*]u8;
pub extern fn jsCreateClass (className: u8, argsPtr: u32) u32;

pub const Null: u32 = 1;
pub const Undefined: u32 = 2;
pub const True: u32 = 3;
pub const False: u32 = 4;

pub const Classes = enum(u8) {
  Uint8Array = 0,
  Request = 1,
  Response = 2,
  Headers = 3,
  FormData = 4,
  File = 5,
  Blob = 6,
  URL = 7,
  URLSearchParams = 8,
  ReadableStream = 9,
  WritableStream = 10,
  TransformStream = 11,
  WebSocketPair = 12,

  pub fn toInt (self: Classes) u8 {
    return @enumToInt(self);
  }
};

pub const JSValue = struct {
  id: u32,

  pub fn init (ptr: u32) JSValue {
    return JSValue{ .id = ptr };
  }

  pub fn free (self: *const JSValue) void {
    jsFree(self.id);
  }
};
