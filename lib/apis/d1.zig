const common = @import("../bindings/common.zig");
const jsFree = common.jsFree;
const DefaultValueSize = common.DefaultValueSize;
const object = @import("../bindings/object.zig");
const Object = object.Object;
const getObjectValue = object.getObjectValue;
const getObjectValueNum = object.getObjectValueNum;
const string = @import("../bindings/string.zig");
const String = string.String;
const getStringFree = string.getStringFree;
const array = @import("../bindings/array.zig");
const Array = array.Array;
const ArrayBuffer = @import("../bindings/arraybuffer.zig").ArrayBuffer;
const function = @import("../bindings/function.zig");
const Function = function.Function;
const AsyncFunction = function.AsyncFunction;

// workers-types TO BE ADDED
pub const D1Database = struct {
  id: u32,

  pub fn init (ptr: u32) D1Database {
    return D1Database{ .id = ptr };
  }

  pub fn free (self: *const D1Database) void {
    jsFree(self.id);
  }

  pub fn prepare (self: *const D1Database, text: []const u8) PreparedStatement {
    const str = String.new(text);
    defer str.free();
    const func = Function{ .id = getObjectValue(self.id, "prepare") };
    defer func.free();

    return PreparedStatement.init(func.callArgs(&str));
  }

  pub fn dump (self: *const D1Database) callconv(.Async) ArrayBuffer {
    const func = AsyncFunction{ .id = getObjectValue(self.id, "dump") };
    defer func.free();

    return ArrayBuffer.init(func.call());
  }

  pub fn exec (self: *const D1Database, query: []const u8) callconv(.Async) Object {
    const str = String.new(query);
    defer str.free();
    const func = AsyncFunction{ .id = getObjectValue(self.id, "exec") };
    defer func.free();

    return Object.init(func.callArgsID(str.id));
  }

  pub fn batch (self: *const D1Database, stmts: []const PreparedStatement) callconv(.Async) BatchSQLSuccess {
    const arr = Array.new();
    defer arr.free();
    for (stmts) |stmt| {
      defer stmt.free();
      arr.push(stmt);
    }
    const func = AsyncFunction{ .id = getObjectValue(self.id, "batch") };
    defer func.free();

    const parentArr = Array.new();
    defer parentArr.free();
    parentArr.push(arr);

    return BatchSQLSuccess.init(func.callArgsID(parentArr.id));
  }
};

pub const BatchSQLSuccess = struct {
  id: u32,

  pub fn init (jsPtr: u32) BatchSQLSuccess {
    return BatchSQLSuccess{ .id = jsPtr };
  }

  pub fn free (self: *const BatchSQLSuccess) void {
    jsFree(self.id);
  }

  pub const BatchSQLSuccessResults = struct {
    arr: Array,
    pos: u32 = 0,
    len: u32,

    pub fn init (jsPtr: u32) BatchSQLSuccessResults {
      const arr = Array.init(jsPtr);
      return BatchSQLSuccessResults{
        .arr = arr,
        .len = arr.length(),
      };
    }

    pub fn free (self: *const BatchSQLSuccessResults) void {
      self.arr.free();
    }

    pub fn next (self: *BatchSQLSuccessResults) ?SQLSuccess {
      if (self.pos == self.len) return null;
      const listkey = self.arr.getType(SQLSuccess, self.pos);
      self.pos += 1;
      return listkey;
    }
  };

  pub fn results (self: *const BatchSQLSuccess) ?BatchSQLSuccessResults {
    const r = getObjectValue(self.id, "results");
    if (r <= DefaultValueSize) return null;
    return BatchSQLSuccessResults.init(r);
  }
};

pub const SQLSuccess = struct {
  id: u32,

  pub fn init (jsPtr: u32) SQLSuccess {
    return SQLSuccess{ .id = jsPtr };
  }

  pub fn free (self: *const SQLSuccess) void {
    jsFree(self.id);
  }

  pub const SQLSuccessResults = struct {
    arr: Array,
    pos: u32 = 0,
    len: u32,

    pub fn init (jsPtr: u32) SQLSuccessResults {
      const arr = Array.init(jsPtr);
      return SQLSuccessResults{
        .arr = arr,
        .len = arr.length(),
      };
    }

    pub fn free (self: *const SQLSuccessResults) void {
      self.arr.free();
    }

    pub fn next (self: *SQLSuccessResults, comptime T: type) ?T {
      if (self.pos == self.len) return null;
      const listkey = self.arr.getType(T, self.pos);
      self.pos += 1;
      return listkey;
    }
  };

  pub fn results (self: *const SQLSuccess) ?SQLSuccessResults {
    const r = getObjectValue(self.id, "results");
    if (r <= DefaultValueSize) return null;
    return SQLSuccessResults.init(r);
  }

  pub fn lastRowId (self: *const SQLSuccess) ?u64 {
    const lrid = getObjectValueNum(self.id, "changes", u64);
    if (lrid <= DefaultValueSize) return null;
    return lrid;
  }

  pub fn changes (self: *const SQLSuccess) u64 {
    return getObjectValueNum(self.id, "changes", u64);
  }

  pub fn duration (self: *const SQLSuccess) u64 {
    return getObjectValueNum(self.id, "duration", u64);
  }
};

pub const PreparedStatement = struct {
  id: u32,

  pub fn init (ptr: u32) PreparedStatement {
    return PreparedStatement{ .id = ptr };
  }

  pub fn free (self: *const PreparedStatement) void {
    jsFree(self.id);
  }

  pub fn statement (self: *const PreparedStatement) []const u8 {
    return getStringFree(getObjectValue(self.id, "statement"));
  }

  pub const ParamsList = struct {
    arr: Array,
    pos: u32 = 0,
    len: u32,

    pub fn init (jsPtr: u32) ParamsList {
      const arr = Array.init(jsPtr);
      return ParamsList{
        .arr = arr,
        .len = arr.length(),
      };
    }

    pub fn free (self: *const ParamsList) void {
      self.arr.free();
    }

    pub fn next (self: *ParamsList, comptime T: type) ?T {
      if (self.pos == self.len) return null;
      const listkey = self.arr.getType(T, self.pos);
      self.pos += 1;
      return listkey;
    }
  };

  pub fn params (self: *const PreparedStatement) ParamsList {
    return ParamsList.init(getObjectValue(self.id, "params"));
  }

  pub fn bind (self: *const PreparedStatement, input: *const Array) PreparedStatement { // input Array<any>
    const func = AsyncFunction{ .id = getObjectValue(self.id, "bind") };
    defer func.free();

    return PreparedStatement.init(func.callArgsID(input.id));
  }

  pub fn first (self: *const PreparedStatement, column: ?[]const u8) callconv(.Async) Object {
    defer self.free();
    const func = AsyncFunction{ .id = getObjectValue(self.id, "first") };
    defer func.free();

    if (column) |c| {
      const str = String.new(c);
      defer str.free();
      return Object.init(func.callArgsID(str.id));
    } else {
      return Object.init(func.call());
    }
  }

  pub fn all (self: *const PreparedStatement) callconv(.Async) SQLSuccess { // SQLSuccess<Array<Object>>
    defer self.free();
    const func = AsyncFunction{ .id = getObjectValue(self.id, "all") };
    defer func.free();

    return SQLSuccess.init(func.call());
  }

  pub fn raw (self: *const PreparedStatement) callconv(.Async) Array { // Array<T>
    defer self.free();
    const func = AsyncFunction{ .id = getObjectValue(self.id, "raw") };
    defer func.free();

    return Array.init(func.call());
  }

  pub fn run (self: *const PreparedStatement) callconv(.Async) SQLSuccess { // SQLSuccess<void> [no results returned]
    defer self.free();
    const func = AsyncFunction{ .id = getObjectValue(self.id, "run") };
    defer func.free();

    return SQLSuccess.init(func.call());
  }
};
