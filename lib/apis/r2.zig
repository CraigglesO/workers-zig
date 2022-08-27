const std = @import("std");
const allocator = std.heap.page_allocator;
const common = @import("../bindings/common.zig");
const jsFree = common.jsFree;
const Null = common.Null;
const DefaultValueSize = common.DefaultValueSize;
const object = @import("../bindings/object.zig");
const Object = object.Object;
const getObjectValue = object.getObjectValue;
const getObjectValueNum = object.getObjectValueNum;
const ArrayBuffer = @import("../bindings/arraybuffer.zig").ArrayBuffer;
const string = @import("../bindings/string.zig");
const String = string.String;
const getStringClean = string.getStringClean;
const Array = @import("../bindings/array.zig").Array;
const ReadableStream = @import("../bindings/streams/readable.zig").ReadableStream;
const AsyncFunction = @import("../bindings/function.zig").AsyncFunction;
const Blob = @import("../bindings/blob.zig").Blob;
const Date = @import("../bindings/date.zig").Date;
const Headers = @import("../bindings/headers.zig").Headers;

pub const R2Value = union(enum) {
  readableStream: *const ReadableStream,
  string: *const String,
  text: []const u8,
  object: *const Object,
  arrayBuffer: *const ArrayBuffer,
  bytes: []const u8,
  blob: *const Blob,
  none,

  pub fn toID (self: *const R2Value) u32 {
    var bodyID: u32 = Null;
    switch (self.*) {
      .readableStream => |rs| return rs.id,
      .string => |s| return s.id,
      .text => |t| return String.new(t).id,
      .object => |obj| return obj.stringify().id,
      .arrayBuffer => |ab| return ab.id,
      .bytes => |b| return ArrayBuffer.new(b).id,
      .blob => |blob| return blob.id,
      .none => return Null,
    }

    return bodyID;
  }

  pub fn free (self: *const R2Value, id: u32) void {
    switch (self.*) {
      .text => jsFree(id),
      .object => jsFree(id),
      .bytes => jsFree(id),
      else => {},
    }
  }
};

pub const R2HTTPMetadata = struct {
  contentType: ?[]const u8 = null,
  contentLanguage: ?[]const u8 = null,
  contentDisposition: ?[]const u8 = null,
  contentEncoding: ?[]const u8 = null,
  cacheControl: ?[]const u8 = null,
  cacheExpiry: ?Date = null,

  pub fn fromObject (r2Object: *const Object) R2HTTPMetadata {
    var contentType: ?[]const u8 = null;
    var contentLanguage: ?[]const u8 = null;
    var contentDisposition: ?[]const u8 = null;
    var contentEncoding: ?[]const u8 = null;
    var cacheControl: ?[]const u8 = null;
    var cacheExpiry: ?Date = null;
    if (r2Object.has("contentType")) r2Object = getStringClean(getObjectValue(r2Object.id, "contentType"));
    return R2HTTPMetadata{
      .contentType = contentType,
      .contentLanguage = contentLanguage,
      .contentDisposition = contentDisposition,
      .contentEncoding = contentEncoding,
      .cacheControl = cacheControl,
      .cacheExpiry = cacheExpiry,
    };
  }
};

pub const R2Range = struct {
  offset: ?u64 = null,
  length: ?u64 = null,
  suffix: ?u64 = null,

  pub fn fromObject (r2Object: *const Object) R2Range {
    var offset: ?u64 = null;
    var length: ?u64 = null;
    var suffix: ?u64 = null;
    if (r2Object.has("offset")) offset = @floatToInt(u64, r2Object.getNum("offset"));
    if (r2Object.has("length")) length = @floatToInt(u64, r2Object.getNum("length"));
    if (r2Object.has("suffix")) suffix = @floatToInt(u64, r2Object.getNum("suffix"));
    return R2Range{
      .offset = offset,
      .length = length,
      .suffix = suffix
    };
  }

  pub fn toObject (self: *const R2Range) Object {
    const obj = Object.new();

    obj.setNum("offset", @intToFloat(f64, self.offset));
    obj.setNum("length", @intToFloat(f64, self.length));
    obj.setNum("suffix", @intToFloat(f64, self.suffix));

    return obj;
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1099
pub const R2Object = struct {
  // NOTE: User must cleanup the slice after use via the std.heap.page_allocator
  pub fn key (self: *const R2Object) []const u8 {
    const str = String.init(getObjectValue(self.id, "key"));
    defer str.free();
    return str.value();
  }

  pub fn version (self: *const R2Object) []const u8 {
    const str = String.init(getObjectValue(self.id, "version"));
    defer str.free();
    return str.value();
  }

  // readonly size: number;
  pub fn size (self: *const R2Object) u64 {
    return @floatToInt(u64, getObjectValueNum(self.id, "size"));
  }

  pub fn etag (self: *const R2Object) []const u8 {
    const str = String.init(getObjectValue(self.id, "etag"));
    defer str.free();
    return str.value();
  }

  pub fn httpEtag (self: *const R2Object) []const u8 {
    const str = String.init(getObjectValue(self.id, "httpEtag"));
    defer str.free();
    return str.value();
  }

  pub fn uploaded (self: *const R2Object) Date {
    const str = Date.init(getObjectValue(self.id, "uploaded"));
    defer str.free();
    return str.value();
  }

  // readonly httpMetadata: R2HTTPMetadata;
  // readonly customMetadata: Record<string, string>;

  pub fn range (self: *const R2Object) R2Range {
    const r2range = Object.init(getObjectValue(self.id, "range"));
    defer r2range.free();
    return R2Range.fromObject(r2range);
  }

  // pub fn writeHttpMetadata(self: *const R2Object, headers: Headers) void {

  // }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1124
pub const R2Objects = struct {

};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1115
pub const R2ObjectBody = struct {

};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1050
pub const R2GetOptions = struct {

};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1131
pub const R2PutOptions = struct {

};

pub const R2GetResponse = union(enum) {
  r2object: R2Object,
  r2objectBody: R2ObjectBody,
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1008
pub const R2Bucket = struct {
  id: u32,

  pub fn init (ptr: u32) R2Bucket {
    return R2Bucket{ .id = ptr };
  }

  pub fn free (self: *const R2Bucket) void {
    jsFree(self.id);
  }

  pub fn head (self: *const R2Bucket, key: []const u8) ?R2Object {
    // prep the string
    const keyStr = String.new(key);
    defer keyStr.free();
    // grab the function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "head") };
    defer func.free();

    const result = func.call();
    if (result <= DefaultValueSize) return null;
    return R2Object{ .id = result };
  }

  pub fn get (
    self: *const R2Bucket,
    key: []const u8,
    options: R2GetOptions
  ) ?R2GetResponse {
    // prep the string
    const keyStr = String.new(key);
    defer keyStr.free();
    // grab options
    const opts = options.toObject();
    defer opts.free();
    // grab the function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "get") };
    defer func.free();
    // prep the args
    const args = Array.new();
    defer args.free();
    args.push(keyStr.id);
    args.push(opts.id);

    const result = func.callArgs(args.id);
    if (result <= DefaultValueSize) return null;
    const body = object.hasObject("body");
    if (body) return R2GetResponse{ .r2objectBody = R2ObjectBody.init(result) };
    return R2GetResponse{ .r2object = R2Object.init(result) };
  }

  pub fn put (
    self: *const R2Bucket,
    key: []const u8,
    value: R2Value,
    options: R2PutOptions
  ) R2Object {
    // prep the string
    const keyStr = String.new(key);
    defer keyStr.free();
    // prep the object
    const val = value.toID();
    defer value.free(val);
    // prep the options
    const opts = options.toObject();
    defer opts.free();
    // grab the function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "put") };
    defer func.free();
    // prep the args
    const args = Array.new();
    defer args.free();
    args.push(keyStr.id);
    args.push(val);
    args.push(opts.id);

    _ = func.callArgs(args.id);
  }

  pub fn delete (self: *const R2Bucket, key: []const u8) void {
    // prep the string
    const str = String.new(key);
    defer str.free();
    // grab the function
    const func = AsyncFunction{ .id = getObjectValue(self.id, "delete") };
    defer func.free();

    _ = func.callArgs(str.id);
  }

  // pub fn list (options: R2ListOptions) R2Objects {

  // }
};
