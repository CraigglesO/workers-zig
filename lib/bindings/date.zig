const common = @import("common.zig");
const jsFree = common.jsFree;
const getNum = common.getNum;
const jsGetClass = common.jsGetClass;
const Classes = common.Classes;
const DefaultValueSize = common.DefaultValueSize;
const object = @import("object.zig");
const getObjectValue = object.getObjectValue;
const Function = @import("function.zig").Function;
const string = @import("string.zig");
const String = string.String;
const getStringFree = string.getStringFree;

// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date
pub const Date = struct {
  id: u32,

  pub fn init (ptr: u32) Date {
    return Date{ .id = ptr };
  }

  pub fn now () f64 {
    const clsPtr = jsGetClass(Classes.Date.toInt());
    defer jsFree(clsPtr);
    const func = Function.init(getObjectValue(clsPtr, "now"));
    defer func.free();
    const res = func.call();
    defer jsFree(res);
    return getNum(res, f64);
  }

  pub fn parseString (str: *const String) ?f64 {
    const clsPtr = jsGetClass(Classes.Date.toInt());
    defer jsFree(clsPtr);
    const func = Function.init(getObjectValue(clsPtr, "parse"));
    defer func.free();
    const res = func.callArgs(str);
    if (res <= DefaultValueSize) return null;
    defer jsFree(res);
    return getNum(res, f64);
  }

  pub fn parseText (str: []const u8) ?f64 {
    const jsStr = String.new(str);
    defer jsStr.free();
    const clsPtr = jsGetClass(Classes.Date.toInt());
    defer jsFree(clsPtr);
    const func = Function.init(getObjectValue(clsPtr, "parse"));
    defer func.free();
    const res = func.callArgs(jsStr);
    if (res <= DefaultValueSize) return null;
    defer jsFree(res);
    return getNum(res, f64);
  }

  pub fn free (self: *const Date) void {
    jsFree(self.id);
  }

  pub fn toString (self: *const Date) String {
    const func = Function.init(getObjectValue(self.id, "toString"));
    defer func.free();
    return String.init(func.call());
  }

  pub fn toText (self: *const Date) []const u8 {
    const func = Function.init(getObjectValue(self.id, "toString"));
    defer func.free();
    return getStringFree(func.call());
  }

  pub fn toUTCString (self: *const Date) String {
    const func = Function.init(getObjectValue(self.id, "toUTCString"));
    defer func.free();
    return String.init(func.call());
  }

  pub fn toUTCText (self: *const Date) []const u8 {
    const func = Function.init(getObjectValue(self.id, "toUTCString"));
    defer func.free();
    return getStringFree(func.call());
  }

  pub fn toISOString (self: *const Date) String {
    const func = Function.init(getObjectValue(self.id, "toISOString"));
    defer func.free();
    return String.init(func.call());
  }

  pub fn toISOText (self: *const Date) []const u8 {
    const func = Function.init(getObjectValue(self.id, "toISOString"));
    defer func.free();
    return getStringFree(func.call());
  }

  pub fn getTime (self: *const Date) f64 {
    const func = Function.init(getObjectValue(self.id, "getTime"));
    defer func.free();
    const res = func.call();
    defer jsFree(res);
    return getNum(res, f64);
  }
};

// TODO:

// Date.UTC()
// Date.UTC(year, month, day, hour, minute, second, millisecond) => number of milliseconds since January 1, 1970, 00:00:00 UTC.

// Date.prototype.getDate()
// Date.prototype.getDay()
// Date.prototype.getFullYear()
// Date.prototype.getHours()
// Date.prototype.getMilliseconds()
// Date.prototype.getMinutes()
// Date.prototype.getMonth()
// Date.prototype.getSeconds()
// Date.prototype.getTimezoneOffset()
// Date.prototype.getUTCDate()
// Date.prototype.getUTCDay()
// Date.prototype.getUTCFullYear()
// Date.prototype.getUTCHours()
// Date.prototype.getUTCMilliseconds()
// Date.prototype.getUTCMinutes()
// Date.prototype.getUTCMonth()
// Date.prototype.getUTCSeconds()
// Date.prototype.setDate()
// Date.prototype.setFullYear()
// Date.prototype.setHours()
// Date.prototype.setMilliseconds()
// Date.prototype.setMinutes()
// Date.prototype.setMonth()
// Date.prototype.setSeconds()
// Date.prototype.setTime()
// Date.prototype.setUTCDate()
// Date.prototype.setUTCFullYear()
// Date.prototype.setUTCHours()
// Date.prototype.setUTCMilliseconds()
// Date.prototype.setUTCMinutes()
// Date.prototype.setUTCMonth()
// Date.prototype.setUTCSeconds()
// Date.prototype.toDateString()
// Date.prototype.toLocaleDateString()
// Date.prototype.toLocaleString()
// Date.prototype.toLocaleTimeString()
// Date.prototype.toTimeString()
// Date.prototype.valueOf()