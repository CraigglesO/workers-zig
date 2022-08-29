const std = @import("std");
const allocator = std.heap.page_allocator;
const common = @import("common.zig");
const jsGetClass = common.jsGetClass;
const jsCreateClass = common.jsCreateClass;
const Classes = common.Classes;
const Undefined = common.Undefined;
const True = common.True;
const jsFree = common.jsFree;
const String = @import("string.zig").String;
const Array = @import("array.zig").Array;
const Function = @import("function.zig").Function;

pub extern fn jsObjectHas(obj: u32, key: u32) u32;
pub extern fn jsObjectSet(obj: u32, key: u32, value: u32) void;
pub extern fn jsObjectSetNum(obj: u32, key: u32, value: f64) void;
pub extern fn jsObjectGet(obj: u32, key: u32) u32;
pub extern fn jsObjectGetNum(obj: u32, key: u32) f64;
pub extern fn jsStringify(obj: u32) u32;
pub extern fn jsParse(str: u32) u32;

pub fn hasObject (obj: u32, key: []const u8) bool {
  const jsKey = String.new(key);
  defer jsKey.free();
  const res = jsObjectHas(obj, jsKey.id);
  return res == True;
}

pub fn getObjectValue (obj: u32, key: []const u8) u32 {
  const jsKey = String.new(key);
  defer jsKey.free();
  return jsObjectGet(obj, jsKey.id);
}

pub fn getObjectValueNum (obj: u32, key: []const u8, comptime T: type) T {
  const jsKey = String.new(key);
  defer jsKey.free();
  const input: f64 = jsObjectGetNum(obj, jsKey.id);
  switch(@typeInfo(T)) {
    .Int => return @floatToInt(T, input),
    .Float => return @floatCast(T, input),
    else => {
      String.new("Can't cast f64 to " ++ @typeName(T)).throw();
      return @as(T, 0);
    },
  }
}

pub fn setObjectValue (obj: u32, key: []const u8, value: u32) void {
  const jsKey = String.new(key);
  defer jsKey.free();
  jsObjectSet(obj, jsKey.id, value);
}

pub fn setObjectValueNum (obj: u32, key: []const u8, comptime T: type, value: T) void {
  const jsKey = String.new(key);
  defer jsKey.free();
  var fValue: f64 = 0;
  switch(@typeInfo(T)) {
    .Int => fValue = @intToFloat(f64, value),
    .Float => fValue = @floatCast(f64, value),
    else => String.new("Can't cast f64 to " ++ @typeName(T)).throw(),
  }
  jsObjectSetNum(obj, jsKey.id, fValue);
}

pub fn setObjectString (obj: u32, key: []const u8, value: []const u8) void {
  const jsKey = String.new(key);
  defer jsKey.free();
  const jsValue = String.new(value);
  defer jsValue.free();
  return jsObjectSet(obj, jsKey.id, jsValue.id);
}

pub const Object = struct {
  id: u32,

  pub fn init (ptr: u32) Object {
    return Object{ .id = ptr };
  }

  pub fn new () Object {
    return Object{ .id = jsCreateClass(Classes.Object.toInt(), Undefined) };
  }

  pub const ListKeys = struct {
    arr: Array,
    pos: u32 = 0,
    len: u32,

    pub fn init (jsPtr: u32) ListKeys {
      const arr = Array.init(jsPtr);
      return ListKeys{
        .arr = arr,
        .len = arr.length(),
      };
    }

    pub fn free (self: *const ListKeys) void {
      self.arr.free();
    }

    pub fn next (self: *ListKeys) ?String {
      if (self.pos == self.len) return null;
      const string = self.arr.getType(String, self.pos);
      self.pos += 1;
      return string;
    }
  };

  pub fn keys (self: *const Object) ListKeys {
    const objClass = jsGetClass(Classes.Object.toInt());
    defer jsFree(objClass);
    const func = Function.init(getObjectValue(objClass, "keys"));
    defer func.free();
    return ListKeys.init(func.callArgs(self));
  }

  pub const ListValues = struct {
    arr: Array,
    pos: u32 = 0,
    len: u32,

    pub fn init (jsPtr: u32) ListValues {
      const arr = Array.init(jsPtr);
      return ListValues{
        .arr = arr,
        .len = arr.length(),
      };
    }

    pub fn free (self: *const ListValues) void {
      self.arr.free();
    }

    pub fn next (self: *ListValues, comptime T: type) ?T {
      if (self.pos == self.len) return null;
      const string = self.arr.getType(T, self.pos);
      self.pos += 1;
      return string;
    }
  };

  pub fn values (self: *const Object) ListValues {
    const objClass = jsGetClass(Classes.Object.toInt());
    defer jsFree(objClass);
    const func = Function.init(getObjectValue(objClass, "values"));
    defer func.free();
    return ListValues.init(func.callArgs(self));
  }

  pub const ListEntries = struct {
    arr: Array,
    pos: u32 = 0,
    len: u32,

    pub const Entry = struct {
      arr: Array,

      pub fn init (jsPtr: u32) Entry {
        return Entry{ .arr = Array.init(jsPtr) };
      }

      pub fn free (self: *const Entry) void {
        jsFree(self.arr.id);
      }

      pub fn key (self: *const Entry) String {
        return String.init(self.arr.get(0));
      }

      pub fn value (self: *const Entry, comptime T: anytype) T {
        return T.init(self.arr.get(1));
      }
    };

    pub fn init (jsPtr: u32) ListEntries {
      const arr = Array.init(jsPtr);
      return ListEntries{
        .arr = arr,
        .len = arr.length(),
      };
    }

    pub fn free (self: *const ListEntries) void {
      self.arr.free();
    }

    pub fn next (self: *ListEntries) ?Entry {
      if (self.pos == self.len) return null;
      const entry = self.arr.getType(Entry, self.pos);
      self.pos += 1;
      return entry;
    }
  };

  pub fn entries (self: *const Object) ListEntries {
    const objClass = jsGetClass(Classes.Object.toInt());
    defer jsFree(objClass);
    const func = Function.init(getObjectValue(objClass, "entries"));
    defer func.free();
    return ListEntries.init(func.callArgs(self));
  }

  pub fn free (self: *const Object) void {
    jsFree(self.id);
  }

  pub fn has (self: *const Object, key: []const u8) bool {
    return hasObject(self.id, key);
  }

  pub fn get (self: *const Object, key: []const u8) u32 {
    return getObjectValue(self.id, key);
  }

  pub fn getNum (self: *const Object, key: []const u8, comptime T: type) T {
    return getObjectValueNum(self.id, key, T);
  }

  pub fn set (self: *const Object, key: []const u8, value: anytype) void {
    return setObjectValue(self.id, key, value.id);
  }

  pub fn setID (self: *const Object, key: []const u8, value: u32) void {
    return setObjectValue(self.id, key, value);
  }

  pub fn setNum (self: *const Object, key: []const u8, comptime T: type, value: T) void {
    return setObjectValueNum(self.id, key, T, value);
  } 

  pub fn setText (self: *const Object, key: []const u8, value: []const u8) void {
    return setObjectString(self.id, key, value);
  }

  pub fn stringify (self: *const Object) String {
    const ptr = jsStringify(self.id);
    return String{ .id = ptr };
  }

  pub fn parse (self: *const Object, comptime T: type) !T {
    const str = self.stringify();
    defer str.free();
    const strValue = str.value();
    defer allocator.free(strValue);
    var stream = std.json.TokenStream.init(strValue);
    return try std.json.parse(T, &stream, .{
      .ignore_unknown_fields = true,
      .allow_trailing_data = true,
      .allocator = allocator,
    });
  }
};
