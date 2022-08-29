const String = @import("string.zig").String;
const Function = @import("function.zig").Function;
const Array = @import("array.zig").Array;
const object = @import("object.zig");
const common = @import("common.zig");
const Undefined = common.Undefined;
const True = common.True;
const Classes = common.Classes;
const JSValue = common.JSValue;
const jsCreateClass = common.jsCreateClass;
const jsFree = common.jsFree;
const getObjectValue = object.getObjectValue;

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L703
// https://developer.mozilla.org/en-US/docs/Web/API/Headers
pub const Headers = struct {
  id: u32,

  pub fn init (jsPtr: u32) Headers {
    return Headers{ .id = jsPtr };
  }

  pub fn new () Headers {
    return Headers{ .id = jsCreateClass(Classes.Headers.toInt(), Undefined) };
  }

  pub fn free (self: *const Headers) void {
    jsFree(self.id);
  }

  pub fn append (self: *const Headers, name: []const u8, value: anytype) void {
    // prepare the name & value
    const jsName = String.new(name);
    defer jsName.free();
    // prepare the function
    const func = Function.init(getObjectValue(self.id, "append"));
    defer func.free();
    // prepare the arguments
    const jsArray = Array.new();
    defer jsArray.free();
    jsArray.push(&jsName);
    jsArray.push(&value);
    // call the function
    const res = JSValue.init(func.callArgs(&jsArray));
    defer res.free();
  }

  pub fn appendText (self: *const Headers, name: []const u8, value: []const u8) void {
    // prepare the name & value
    const jsName = String.new(name);
    defer jsName.free();
    const jsValue = String.new(value);
    defer jsValue.free();
    // prepare the function
    const func = Function.init(getObjectValue(self.id, "append"));
    defer func.free();
    // prepare the arguments
    const jsArray = Array.new();
    defer jsArray.free();
    jsArray.push(&jsName);
    jsArray.push(&jsValue);
    // call the function
    const res = JSValue.init(func.callArgs(&jsArray));
    defer res.free();
  }

  pub fn get (self: *const Headers, name: []const u8) ?String {
    // prepare the name
    const jsName = String.init(name);
    defer jsName.free();
    // prepare the function
    const func = Function.init(getObjectValue(self.id, "get"));
    defer func.free();
    // call the function
    const result = func.callArgs(&jsName);
    // return the result
    if (result == Undefined) {
      return;
    }
    return String.init(result);
  }

  // TODO:
  // pub fn getAll (name: []const u8) ?[]const u8 {

  // }

  pub fn has (self: *const Headers, name: []const u8) bool {
    // prepare the name
    const jsName = String.init(name);
    defer jsName.free();
    // prepare the function
    const func = Function.init(getObjectValue(self.id, "has"));
    defer func.free();
    // call the function
    const result = func.callArgs(&jsName);
    return result == True;
  }

  pub fn set (self: *const Headers, name: []const u8, value: anytype) void {
    // prepare the name & value
    const jsName = String.new(name);
    defer jsName.free();
    // prepare the function
    const func = Function.init(getObjectValue(self.id, "set"));
    defer func.free();
    // prepare the arguments
    const jsArray = Array.new();
    defer jsArray.free();
    jsArray.push(&jsName);
    jsArray.push(&value);
    // call the function
    const res = JSValue.init(func.callArgs(&jsArray));
    defer res.free();
  }
  
  pub fn setText (self: *const Headers, name: []const u8, value: []const u8) void {
    // prepare the name & value
    const jsName = String.new(name);
    defer jsName.free();
    const jsValue = String.new(value);
    defer jsValue.free();
    // prepare the function
    const func = Function.init(getObjectValue(self.id, "set"));
    defer func.free();
    // prepare the arguments
    const jsArray = Array.new();
    defer jsArray.free();
    jsArray.push(&jsName);
    jsArray.push(&jsValue);
    // call the function
    const res = JSValue.init(func.callArgs(&jsArray));
    defer res.free();
  }

  pub fn delete (self: *const Headers, name: []const u8) void {
    // prepare the name
    const jsName = String.new(name);
    defer jsName.free();
    // prepare the function
    const func = Function.init(getObjectValue(self.id, "delete"));
    defer func.free();
    // call the function
    const res = JSValue.init(func.callArgs(&jsName));
    defer res.free();
  }

  // TODO:
  // pub fn keys () ?[]String {

  // }

  // TODO:
  // pub fn values () ?[]String {

  // }

  // TODO:
  // pub fn entries () { key: []u8, value: []u8 }
};
