const std = @import("std");
const allocator = std.heap.page_allocator;
const common = @import("common.zig");
const jsFree = common.jsFree;
const jsGetClass = common.jsGetClass;
const Classes = common.Classes;
const getStringClean = @import("string.zig").getStringClean;
const object = @import("object.zig");
const getObjectValue = object.getObjectValue;
const hasObject = object.hasObject;
const Array = @import("array.zig").Array;
const String = @import("string.zig").String;
const Function = @import("function.zig").Function;

pub const Record = struct {
  id: u32,

  pub fn init (ptr: u32) Record {
    return Record{ .id = ptr };
  }

  pub const ListStrings = struct {
    arr: Array,
    pos: u32 = 0,
    len: u32,

    pub fn init (jsPtr: u32) ListStrings {
      const arr = Array.init(jsPtr);
      return ListStrings{
        .arr = arr,
        .len = arr.length(),
      };
    }

    pub fn free (self: *const ListStrings) void {
      self.arr.free();
    }

    pub fn next (self: *ListStrings) ?String {
      if (self.pos == self.len) return null;
      const string = self.arr.getType(String, self.pos);
      self.pos += 1;
      return string;
    }
  };

  pub fn keys (self: *const Record) ListStrings {
    const objClass = jsGetClass(Classes.Object.toInt());
    defer jsFree(objClass);
    const func = Function.init(getObjectValue(objClass, "keys"));
    defer func.free();
    return ListStrings.init(func.callArgs(self));
  }

  pub fn values (self: *const Record) ListStrings {
    const objClass = jsGetClass(Classes.Object.toInt());
    defer jsFree(objClass);
    const func = Function.init(getObjectValue(objClass, "values"));
    defer func.free();
    return ListStrings.init(func.callArgs(self));
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

      pub fn value (self: *const Entry) String {
        return String.init(self.arr.get(1));
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

  pub fn entries (self: *const Record) ListEntries {
    const objClass = jsGetClass(Classes.Object.toInt());
    defer jsFree(objClass);
    const func = Function.init(getObjectValue(objClass, "entries"));
    defer func.free();
    return ListEntries.init(func.callArgs(self));
  }

  pub fn free (self: *const Record) void {
    jsFree(self.id);
  }

  pub fn has (self: *const Record, key: []const u8) bool {
    return hasObject(self.id, key);
  }

  pub fn get (self: *const Record, key: []const u8) []const u8 {
    return getStringClean(getObjectValue(self.id, key));
  }
};
