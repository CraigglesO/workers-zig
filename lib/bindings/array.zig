const common = @import("common.zig");
const jsCreateClass = common.jsCreateClass;
const jsFree = common.jsFree;
const jsSize = common.jsSize;
const Classes = common.Classes;
const Undefined = common.Undefined;
const String = @import("string.zig").String;

pub extern fn jsArrayPush(arrID: u32, args: u32) void;
pub extern fn jsArrayGet(arrID: u32, pos: u32) u32;
pub extern fn jsArrayGetNum(arrID: u32, pos: u32) f64;

pub const Array = struct {
  id: u32,

  pub fn init (ptr: u32) Array {
    return Array{ .id = ptr };
  }

  pub fn new () Array {
    return Array{ .id = jsCreateClass(Classes.Array.toInt(), Undefined) };
  }

  pub fn free (self: *const Array) void {
    jsFree(self.id);
  }

  pub fn push (self: *const Array, jsValue: anytype) void {
    jsArrayPush(self.id, jsValue.id);
  }

  pub fn pushID (self: *const Array, jsPtr: u32) void {
    jsArrayPush(self.id, jsPtr);
  }

  pub fn pushString (self: *const Array, str: []const u8) void {
    const jsStr = String.new(str);
    defer jsStr.free();
    jsArrayPush(self.id, jsStr.id);
  }

  pub fn get (self: *const Array, pos: u32) u32 {
    return jsArrayGet(self.id, pos);
  }

  pub fn getNum (self: *const Array, pos: u32, comptime T: type) T {
    const num = jsArrayGetNum(self.id, pos);
    switch(@typeInfo(T)) {
      .Int => return @floatToInt(T, num),
      .Float => return @floatCast(T, num),
      else => {
        String.new("Can't cast f64 to " ++ @typeName(T)).throw();
        return @as(T, 0);
      },
    }
  }

  pub fn getType (self: *const Array, comptime T: type, pos: u32) T {
    const id = jsArrayGet(self.id, pos);
    return T.init(id);
  }

  pub fn length (self: *const Array) u32 {
    return jsSize(self.id);
  }
};
