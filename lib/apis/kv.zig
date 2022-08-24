const std = @import("std");
const allocator = std.heap.page_allocator;
const common = @import("../bindings/common.zig");
const jsFree = common.jsFree;
const Undefined = common.Undefined;
const DefaultValueSize = common.DefaultValueSize;
const object = @import("../bindings/object.zig");
const Object = object.Object;
const getObjectValue = object.getObjectValue;
const ArrayBuffer = @import("../bindings/arraybuffer.zig").ArrayBuffer;
const String = @import("../bindings/string.zig").String;
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
    if (self.cacheTtl != null) obj.setNum("cacheTtl", @intToFloat(f64, self.cacheTtl.?));

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
    var id: u32 = Undefined;
    switch (self.*) {
      .text => |str| id = String.new(str).id,
      .string => |str| id = str.id,
      .object => |obj| id = obj.stringify().id,
      .bytes => |bytes| id = ArrayBuffer.new(bytes).id,
      .arrayBuffer => |ab| id = ab.id,
      .readableStream => |rStream| id = rStream.id,
    }

    return id;
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L960
pub const PutOptions = struct {
  expiration: ?u64 = null, // secondsSinceEpoch
  expirationTtl: ?u64 = null, // secondsFromNow
  metadata: ?*const Object = null,

  pub fn toObject (self: *const PutOptions) Object {
    const obj = Object.new();

    if (self.expiration != null) obj.setNum("expiration", @intToFloat(f64, self.expiration.?));
    if (self.expirationTtl != null) obj.setNum("expirationTtl", @intToFloat(f64, self.expirationTtl.?));
    if (self.metadata != null) obj.set("metadata", self.metadata.?.id);

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

    obj.setNum("limit", @intToFloat(f64, self.limit));
    if (self.prefix != null) obj.setString("prefix", self.prefix.?);
    if (self.jsPrefix != null) obj.set("prefix", self.jsPrefix.?.id);
    if (self.cursor != null) obj.setString("cursor", self.cursor.?);
    if (self.jsCursor != null) obj.setS("cursor", self.jsCursor.?.id);

    return obj;
  }
};

// pub const ListResponse = struct {
//   id: u32,
  
//   pub fn init (id: u32) ListResponse {
//     return ListResponse{ .id = id };
//   }

//   pub fn count () usize {

//   }

//   pub fn get (index: usize) ListKey {

//   }

//   pub fn cursor () []u8 {

//   }

//   pub fn listComplete () bool {

//   }

//   pub const ListKey = struct {
//     id: u32,

//     pub fn name () []u8 {

//     }

//     pub fn metadata (comptime T: type) !T {

//     }
//   };
// };

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
    defer jsFree(val);
    // prep the options
    const opts = options.toObject();
    defer opts.free();
    // grab the function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "put") };
    defer func.free();
    // prep the args
    const args = Array.new();
    defer args.free();
    args.push(str.id);
    args.push(val);
    args.push(opts.id);

    _ = func.callArgs(args.id);
  }

  pub fn getString (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions
  ) ?String {
    // prep the string
    const str = String.new(key);
    defer str.free();
    // grab options
    const opts = options.toObject();
    defer opts.free();
    opts.setString("type", "text");
    // grab the function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "get") };
    defer func.free();
    // prep the args
    const args = Array.new();
    defer args.free();
    args.push(str.id);
    args.push(opts.id);

    const result = func.callArgs(args.id);
    if (result <= DefaultValueSize) return null;
    return String{ .id = result };
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

  pub fn getObject (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions
  ) ?Object {
    // prep the string
    const str = String.new(key);
    defer str.free();
    // grab options
    const opts = options.toObject();
    defer opts.free();
    opts.setString("type", "json");
    // grab the function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "get") };
    defer func.free();
    // prep the args
    const args = Array.new();
    defer args.free();
    args.push(str.id);
    args.push(opts.id);

    const result = func.callArgs(args.id);
    if (result <= DefaultValueSize) return null;
    return Object{ .id = result };
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
    // prep the string
    const str = String.new(key);
    defer str.free();
    // grab options
    const opts = options.toObject();
    defer opts.free();
    opts.setString("type", "arrayBuffer");
    // grab the function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "get") };
    defer func.free();
    // prep the args
    const args = Array.new();
    defer args.free();
    args.push(str.id);
    args.push(opts.id);

    const result = func.callArgs(args.id);
    if (result <= DefaultValueSize) return null;
    return ArrayBuffer{ .id = result };
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

  pub fn getStream (
    self: *const KVNamespace,
    key: []const u8,
    options: GetOptions
  ) ?ReadableStream {
    // prep the string
    const str = String.new(key);
    defer str.free();
    // grab options
    const opts = options.toObject();
    defer opts.free();
    opts.setString("type", "stream");
    // grab the function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "get") };
    defer func.free();
    // prep the args
    const args = Array.new();
    defer args.free();
    args.push(str.id);
    args.push(opts.id);

    const result = func.callArgs(args.id);
    if (result <= DefaultValueSize) return null;
    return ReadableStream{ .id = result };
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

    _ = func.callArgs(str.id);
  }

  // pub fn list (options: ?ListOptions) ListResponse {

  // }
};
