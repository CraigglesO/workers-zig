const std = @import("std");
const allocator = std.heap.page_allocator;
const common = @import("../bindings/common.zig");
const jsFree = common.jsFree;
const True = common.True;
const Null = common.Null;
const DefaultValueSize = common.DefaultValueSize;
const object = @import("../bindings/object.zig");
const Object = object.Object;
const getObjectValue = object.getObjectValue;
const getObjectValueNum = object.getObjectValueNum;
const jsParse = object.jsParse;
const ArrayBuffer = @import("../bindings/arraybuffer.zig").ArrayBuffer;
const string = @import("../bindings/string.zig");
const String = string.String;
const getStringFree = string.getStringFree;
const Array = @import("../bindings/array.zig").Array;
const ReadableStream = @import("../bindings/streams/readable.zig").ReadableStream;
const AsyncFunction = @import("../bindings/function.zig").AsyncFunction;

pub const KV_MAX_SIZE = 25 * 1_000 * 1_000; // 25MiB

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L932
// Note: To simplify, we getX rather than applying type to the options.
pub const GetOptions = struct {
  cacheTtl: ?u64 = null,

  pub fn toObject (self: *const GetOptions) Object {
    const obj = Object.new();
    if (self.cacheTtl != null) obj.setNum("cacheTtl", u64, self.cacheTtl.?);

    return obj;
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L890
pub const PutValue = union(enum) {
  text: []const u8,
  string: *const String,
  object: *const Object,
  bytes: []const u8,
  arrayBuffer: *const ArrayBuffer,
  readableStream: *const ReadableStream,

  pub fn toID (self: *const PutValue) u32 {
    switch (self.*) {
      .text => |str| return String.new(str).id,
      .string => |str| return str.id,
      .object => |obj| return obj.stringify().id,
      .bytes => |bytes| return ArrayBuffer.new(bytes).id,
      .arrayBuffer => |ab| return ab.id,
      .readableStream => |rStream| return rStream.id,
    }
  }

  pub fn free (self: *const PutValue, id: u32) void {
    switch (self.*) {
      .text => jsFree(id),
      .object => jsFree(id),
      .bytes => jsFree(id),
      else => {},
    }
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L960
pub const PutOptions = struct {
  expiration: ?u64 = null, // secondsSinceEpoch
  expirationTtl: ?u64 = null, // secondsFromNow
  metadata: ?*const Object = null,

  pub fn toObject (self: *const PutOptions) Object {
    const obj = Object.new();

    if (self.expiration != null) obj.setNum("expiration", u64, self.expiration.?);
    if (self.expirationTtl != null) obj.setNum("expirationTtl", u64, self.expirationTtl.?);
    if (self.metadata != null) obj.set("metadata", self.metadata.?);

    return obj;
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L948
pub const ListOptions = struct {
  limit: u16 = 1_000,
  prefix: ?[]const u8 = null,
  jsPrefix: ?*const String = null,
  cursor: ?[]const u8 = null,
  jsCursor: ?*const String = null,

  pub fn toObject (self: *const ListOptions) Object {
    const obj = Object.new();

    obj.setNum("limit", u16, self.limit);
    if (self.prefix != null) obj.setText("prefix", self.prefix.?);
    if (self.jsPrefix != null) obj.set("prefix", self.jsPrefix.?);
    if (self.cursor != null) obj.setText("cursor", self.cursor.?);
    if (self.jsCursor != null) obj.set("cursor", self.jsCursor.?);

    return obj;
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L954
pub const ListResult = struct {
  id: u32,
  
  pub fn init (id: u32) ListResult {
    return ListResult{ .id = id };
  }

  pub fn free (self: *const ListResult) void {
    jsFree(self.id);
  }

  pub fn keys (self: *const ListResult) ListKeys {
    return ListKeys.init(getObjectValue(self.id, "keys"));
  }

  pub fn cursor (self: *const ListResult) []const u8 {
    return getStringFree(getObjectValue(self.id, "cursor"));
  }

  pub fn listComplete (self: *const ListResult) bool {
    const jsPtr = getObjectValue(self.id, "list_complete");
    return jsPtr == True;
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

    pub fn next (self: *ListKeys) ?ListKey {
      if (self.pos == self.len) return null;
      const listkey = self.arr.getType(ListKey, self.pos);
      self.pos += 1;
      return listkey;
    }
  };

  pub const ListKey = struct {
    id: u32,

    pub fn init (jsPtr: u32) ListKey {
      return ListKey{ .id = jsPtr };
    }

    pub fn free (self: *const ListKey) void {
      jsFree(self.id);
    }

    pub fn name (self: *const ListKey) []const u8 {
      return getStringFree(getObjectValue(self.id, "name"));
    }

    pub fn expiration (self: *const ListKey) ?u64 {
      const num = getObjectValueNum(self.id, "expiration", u64);
      if (num <= DefaultValueSize) return null;
      return num;
    }

    pub fn metadata (self: *const ListKey, comptime T: type) ?T {
      const obj = self.metaObject() orelse return null;
      defer obj.free();
      return obj.parse(T) orelse null;
    }

    pub fn metaObject (self: *const ListKey) ?Object {
      const objPtr = getObjectValue(self.id, "metadata");
      if (objPtr <= DefaultValueSize) return null;
      return Object.init(objPtr);
    }
  };
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L852
// Workers KV is a global, low-latency, key-value data store.
// It supports exceptionally high read volumes with low-latency,
// making it possible to build highly dynamic APIs and websites
// which respond as quickly as a cached static file would.
pub const KVNamespace = struct {
  id: u32,

  pub fn init (ptr: u32) KVNamespace {
    return KVNamespace{ .id = ptr };
  }

  pub fn free (self: *const KVNamespace) void {
    jsFree(self.id);
  }

  pub fn put (
    self: *const KVNamespace,
    key: []const u8,
    value: PutValue,
    options: PutOptions
  ) void {
    // prep the string
    const str = String.new(key);
    defer str.free();
    // prep the object
    const val = value.toID();
    defer value.free(val);
    // prep the options
    const opts = options.toObject();
    defer opts.free();
    // grab the function
    const func = AsyncFunction.init(getObjectValue(self.id, "put"));
    defer func.free();
    // prep the args
    const args = Array.new();
    defer args.free();
    args.push(&str);
    args.pushID(val);
    args.push(&opts);

    _ = func.callArgsID(args.id);
  }

  pub fn putMetadata (
    self: *const KVNamespace,
    key: []const u8,
    value: PutValue,
    comptime T: type,
    metadata: T,
    options: PutOptions
  ) void {
    // prep the string
    const str = String.new(key);
    defer str.free();
    // prep the object
    const val = value.toID();
    defer value.free(val);
    // metadata -> string -> Object -> options.metadata.
    var buf: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var metaBuf = std.ArrayList(u8).init(fba.allocator());
    std.json.stringify(metadata, .{}, metaBuf.writer()) catch {
      String.new("Failed to stringify " ++ @typeName(T)).throw();
      return;
    };
    const metaString = String.new(metaBuf.items);
    defer metaString.free();
    const metaObj = Object.init(jsParse(metaString.id));
    defer metaObj.free();
    // prep the options
    const newOptions = PutOptions{
      .expiration = options.expiration,
      .expirationTtl = options.expirationTtl,
      .metadata = &metaObj,
    };
    const opts = newOptions.toObject();
    defer opts.free();
    // grab the function
    const func = AsyncFunction.init(getObjectValue(self.id, "put"));
    defer func.free();
    // prep the args
    const args = Array.new();
    defer args.free();
    args.push(&str);
    args.pushID(val);
    args.push(&opts);

    _ = func.callArgsID(args.id);
  }

  fn _get (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions,
    resType: []const u8,
  ) u32 {
    // prep the string
    const str = String.new(key);
    defer str.free();
    // grab options
    const opts = options.toObject();
    defer opts.free();
    opts.setText("type", resType);
    // grab the function
    const func = AsyncFunction.init(getObjectValue(self.id, "get"));
    defer func.free();
    // prep the args
    const args = Array.new();
    defer args.free();
    args.push(&str);
    args.push(&opts);

    return func.callArgsID(args.id);
  }

  fn _getMeta (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions,
    resType: []const u8,
  ) u32 {
    // prep the string
    const str = String.new(key);
    defer str.free();
    // grab options
    const opts = options.toObject();
    defer opts.free();
    opts.setText("type", resType);
    // grab the function
    const func = AsyncFunction.init(getObjectValue(self.id, "getWithMetadata"));
    defer func.free();
    // prep the args
    const args = Array.new();
    defer args.free();
    args.push(&str);
    args.push(&opts);

    return func.callArgsID(args.id);
  }

  pub fn getString (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions
  ) ?String {
    const result = self._get(key, options, "text");
    if (result <= DefaultValueSize) return null;
    return String{ .id = result };
  }

  pub const KVStringMetadata = struct {
    value: String,
    metadata: ?Object,

    pub fn init (valuePtr: u32, metaPtr: u32) KVStringMetadata {
      var metadata: ?Object = null;
      if (metaPtr > DefaultValueSize) metadata = Object.init(metaPtr);
      return KVStringMetadata{
        .value = String.init(valuePtr),
        .metadata = metadata,
      };
    }

    pub fn free (self: *const KVStringMetadata) void {
      self.value.free();
      self.metadata.?.free();
    }
  };

  pub fn getStringWithMetadata (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions
  ) ?KVStringMetadata {
    const result = self._getMeta(key, options, "text");
    if (result <= DefaultValueSize) return null;
    const resObj = Object.init(result);
    defer resObj.free();
    return KVStringMetadata.init(resObj.get("value"), resObj.get("metadata"));
  }

  pub fn getText (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions
  ) ?[]const u8 {
    const str = self.getString(key, options) orelse return null;
    defer str.free();
    return str.value();
  }

  pub const KVTextMetadata = struct {
    value: []const u8,
    metadata: ?Object,

    pub fn init (value: []const u8, metadata: ?Object) KVTextMetadata {
      return KVTextMetadata{
        .value = value,
        .metadata = metadata,
      };
    }

    pub fn free (self: *const KVTextMetadata) void {
      allocator.free(self.value);
      self.metadata.?.free();
    }
  };

  pub fn getTextWithMetadata (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions
  ) ?KVTextMetadata {
    const strMeta = self.getStringWithMetadata(key, options);
    if (strMeta == null) return null;
    defer strMeta.?.value.free();
    return KVTextMetadata.init(strMeta.?.value.value(), strMeta.?.metadata);
  }

  pub fn getObject (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions
  ) ?Object {
    const result = self._get(key, options, "json");
    if (result <= DefaultValueSize) return null;
    return Object{ .id = result };
  }

  pub const KVObjectMetadata = struct {
    value: Object,
    metadata: ?Object,

    pub fn init (valuePtr: u32, metaPtr: u32) KVObjectMetadata {
      var metadata: ?Object = null;
      if (metaPtr > DefaultValueSize) metadata = Object.init(metaPtr);
      return KVObjectMetadata{
        .value = Object.init(valuePtr),
        .metadata = metadata,
      };
    }

    pub fn free (self: *const KVObjectMetadata) void {
      self.value.free();
      self.metadata.?.free();
    }
  };

  pub fn getObjectWithMetadata (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions
  ) ?KVObjectMetadata {
    const result = self._getMeta(key, options, "json");
    if (result <= DefaultValueSize) return null;
    const resObj = Object.init(result);
    defer resObj.free();
    return KVObjectMetadata.init(resObj.get("value"), resObj.get("metadata"));
  }

  // NOTE: data must be freed by the caller
  pub fn getJSON (
    self: *const KVNamespace,
    comptime T: type,
    key: []const u8,
    options: GetOptions
  ) ?T {
    // grab the data as a string
    const text = self.getText(key, options) orelse return null;
    defer allocator.free(text);
    // parse the result
    var stream = std.json.TokenStream.init(text);
    return std.json.parse(T, &stream, .{
      .ignore_unknown_fields = true,
      .allow_trailing_data = true,
      .allocator = allocator,
    }) catch return null;
  }

  pub fn getArrayBuffer (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions
  ) ?ArrayBuffer {
    const result = self._get(key, options, "arrayBuffer");
    if (result <= DefaultValueSize) return null;
    return ArrayBuffer{ .id = result };
  }

  pub const KVArrayBufferMetadata = struct {
    value: ArrayBuffer,
    metadata: ?Object,

    pub fn init (valuePtr: u32, metaPtr: u32) KVArrayBufferMetadata {
      var metadata: ?Object = null;
      if (metaPtr > DefaultValueSize) metadata = Object.init(metaPtr);
      return KVArrayBufferMetadata{
        .value = ArrayBuffer.init(valuePtr),
        .metadata = metadata,
      };
    }

    pub fn free (self: *const KVArrayBufferMetadata) void {
      self.value.free();
      self.metadata.?.free();
    }
  };

  pub fn getArrayBufferWithMetadata (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions
  ) ?KVArrayBufferMetadata {
    const result = self._getMeta(key, options, "arrayBuffer");
    if (result <= DefaultValueSize) return null;
    const resObj = Object.init(result);
    defer resObj.free();
    return KVArrayBufferMetadata.init(resObj.get("value"), resObj.get("metadata"));
  }

  // NOTE: free bytes after use
  pub fn getBytes (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions
  ) ?[]const u8 {
    const ab = self.getArrayBuffer(key, options) orelse return null;
    defer ab.free();
    return ab.bytes();
  }

  pub const KVBytesMetadata = struct {
    value: []const u8,
    metadata: ?Object,

    pub fn init (value: []const u8, metadata: ?Object) KVBytesMetadata {
      return KVBytesMetadata{
        .value = value,
        .metadata = metadata,
      };
    }

    pub fn free (self: *const KVBytesMetadata) void {
      allocator.free(self.value);
      self.metadata.?.free();
    }
  };

  pub fn getBytesWithMetadata (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions
  ) ?KVBytesMetadata {
    const abMeta = self.getArrayBufferWithMetadata(key, options);
    if (abMeta == null) return null;
    defer abMeta.?.value.free();
    return KVBytesMetadata.init(abMeta.?.value.bytes(), abMeta.?.metadata);
  }

  pub fn getStream (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions
  ) ?ReadableStream {
    const result = self._get(key, options, "stream");
    if (result <= DefaultValueSize) return null;
    return ReadableStream.init(result);
  }

  pub const KVStreamMetadata = struct {
    value: ReadableStream,
    metadata: ?Object,

    pub fn init (valuePtr: u32, metaPtr: u32) KVStreamMetadata {
      var metadata: ?Object = null;
      if (metaPtr > DefaultValueSize) metadata = Object.init(metaPtr);
      return KVStreamMetadata{
        .value = ReadableStream.init(valuePtr),
        .metadata = metadata,
      };
    }

    pub fn free (self: *const KVStreamMetadata) void {
      self.value.free();
      self.metadata.?.free();
    }
  };

  pub fn getStreamWithMetadata (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions
  ) ?KVStreamMetadata {
    const result = self._getMeta(key, options, "stream");
    if (result <= DefaultValueSize) return null;
    const resObj = Object.init(result);
    defer resObj.free();
    return KVStreamMetadata.init(resObj.get("value"), resObj.get("metadata"));
  }

  pub fn delete (
    self: *const KVNamespace,
    key: []const u8
  ) void {
    // prep the string
    const str = String.new(key);
    defer str.free();
    // grab the function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "delete") };
    defer func.free();

    _ = func.callArgsID(str.id);
  }

  pub fn list (self: *const KVNamespace, options: ListOptions) ListResult {
    // prep the opts
    const opts = options.toObject();
    defer opts.free();
    // grab the function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "list") };
    defer func.free();

    return ListResult.init(func.callArgsID(opts.id));
  }
};
