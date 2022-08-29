const std = @import("std");
const allocator = std.heap.page_allocator;
const common = @import("../bindings/common.zig");
const jsFree = common.jsFree;
const Null = common.Null;
const True = common.True;
const DefaultValueSize = common.DefaultValueSize;
const object = @import("../bindings/object.zig");
const Object = object.Object;
const getObjectValue = object.getObjectValue;
const getObjectValueNum = object.getObjectValueNum;
const ArrayBuffer = @import("../bindings/arraybuffer.zig").ArrayBuffer;
const string = @import("../bindings/string.zig");
const String = string.String;
const getStringFree = string.getStringFree;
const Array = @import("../bindings/array.zig").Array;
const ReadableStream = @import("../bindings/streams/readable.zig").ReadableStream;
const AsyncFunction = @import("../bindings/function.zig").AsyncFunction;
const Blob = @import("../bindings/blob.zig").Blob;
const Date = @import("../bindings/date.zig").Date;
const Headers = @import("../bindings/headers.zig").Headers;
const Record = @import("../bindings/record.zig").Record;

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

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1066
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
    if (r2Object.has("contentType")) r2Object = getStringFree(getObjectValue(r2Object.id, "contentType"));
    if (r2Object.has("contentLanguage")) r2Object = getStringFree(getObjectValue(r2Object.id, "contentLanguage"));
    if (r2Object.has("contentDisposition")) r2Object = getStringFree(getObjectValue(r2Object.id, "contentDisposition"));
    if (r2Object.has("contentEncoding")) r2Object = getStringFree(getObjectValue(r2Object.id, "contentEncoding"));
    if (r2Object.has("cacheControl")) r2Object = getStringFree(getObjectValue(r2Object.id, "cacheControl"));
    if (r2Object.has("cacheExpiry")) r2Object = getStringFree(getObjectValue(r2Object.id, "cacheExpiry"));
    return R2HTTPMetadata{
      .contentType = contentType,
      .contentLanguage = contentLanguage,
      .contentDisposition = contentDisposition,
      .contentEncoding = contentEncoding,
      .cacheControl = cacheControl,
      .cacheExpiry = cacheExpiry,
    };
  }

  pub fn writeHttpMetadata (self: *const R2HTTPMetadata, headers: Headers) void {
    if (self.contentType) headers.setText("Content-Type", self.contentType.?.id);
    if (self.contentLanguage) headers.setText("Content-Language", self.contentLanguage.?.id);
    if (self.contentDisposition) headers.setText("Content-Disposition", self.contentDisposition.?.id);
    if (self.contentEncoding) headers.setText("Content-Encoding", self.contentEncoding.?.id);
    if (self.cacheControl) headers.setText("Cache-Control", self.cacheControl.?.id);
    if (self.cacheExpiry) headers.setText("Cache-Expiry", self.cacheExpiry.?.id);
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
    if (r2Object.has("offset")) offset = r2Object.getNum("offset", u64);
    if (r2Object.has("length")) length = r2Object.getNum("length", u64);
    if (r2Object.has("suffix")) suffix = r2Object.getNum("suffix", u64);
    return R2Range{
      .offset = offset,
      .length = length,
      .suffix = suffix
    };
  }

  pub fn toObject (self: *const R2Range) Object {
    const obj = Object.new();

    obj.setNum("offset", u64, self.offset);
    obj.setNum("length", u64, self.length);
    obj.setNum("suffix", u64, self.suffix);

    return obj;
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1099
pub const R2Object = struct {
  // NOTE: User must cleanup the slice after use via the std.heap.page_allocator
  pub fn key (self: *const R2Object) []const u8 {
    return getStringFree(getObjectValue(self.id, "key"));
  }

  pub fn version (self: *const R2Object) []const u8 {
    return getStringFree(getObjectValue(self.id, "version"));
  }

  // readonly size: number;
  pub fn size (self: *const R2Object) u64 {
    return getObjectValueNum(self.id, "size", u64);
  }

  pub fn etag (self: *const R2Object) []const u8 {
    return getStringFree(getObjectValue(self.id, "etag"));
  }

  pub fn httpEtag (self: *const R2Object) []const u8 {
    return getStringFree(getObjectValue(self.id, "httpEtag"));
  }

  pub fn uploaded (self: *const R2Object) Date {
    return Date.init(getObjectValue(self.id, "uploaded"));
  }

  pub fn httpMetadata (self: *const R2Object) R2HTTPMetadata {
    return R2HTTPMetadata.init(getObjectValue(self.id, "httpMetadata"));
  }

  pub fn customMetadata (self: *const R2Object) Record {
    return Record.init(getObjectValue(self.id, "customMetadata"));
  }

  pub fn range (self: *const R2Object) R2Range {
    const r2range = Object.init(getObjectValue(self.id, "range"));
    defer r2range.free();
    return R2Range.fromObject(r2range);
  }

  pub fn writeHttpMetadata (self: *const R2Object, headers: Headers) void {
    const httpMeta = self.httpMetadata();
    httpMeta.writeHttpMetadata(headers);
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1115
pub const R2ObjectBody = struct {
  pub fn bodyUsed (self: *const R2ObjectBody) bool {
    const used = getObjectValue(self.id, "bodyUsed");
    return used == True;
  }

  pub fn arrayBuffer (self: *const R2ObjectBody) ArrayBuffer {
    const func = AsyncFunction.init(getObjectValue(self.id, "arrayBuffer"));
    defer func.free();

    return ArrayBuffer.init(func.call());
  }

  pub fn text (self: *const R2ObjectBody) String {
    const func = AsyncFunction.init(getObjectValue(self.id, "text"));
    defer func.free();

    return String.init(func.call());
  }

  pub fn object (self: *const R2ObjectBody) Object {
    const func = AsyncFunction.init(getObjectValue(self.id, "json"));
    defer func.free();

    return Object.init(func.call());
  }

  pub fn json (self: *const R2ObjectBody, comptime T: type) T {
    const func = AsyncFunction.init(getObjectValue(self.id, "json"));
    defer func.free();

    const obj = Object.init(func.call());
    return obj.parse(T);
  }

  pub fn blob (self: *const R2ObjectBody) Blob {
    const func = AsyncFunction.init(getObjectValue(self.id, "blob"));
    defer func.free();

    return Blob.init(func.call());
  }

  // NOTE: User must cleanup the slice after use via the std.heap.page_allocator
  pub fn key (self: *const R2ObjectBody) []const u8 {
    return getStringFree(getObjectValue(self.id, "key"));
  }

  pub fn version (self: *const R2ObjectBody) []const u8 {
    return getStringFree(getObjectValue(self.id, "version"));
  }

  // readonly size: number;
  pub fn size (self: *const R2ObjectBody) u64 {
    return getObjectValueNum(self.id, "size", u64);
  }

  pub fn etag (self: *const R2ObjectBody) []const u8 {
    return getStringFree(getObjectValue(self.id, "etag"));
  }

  pub fn httpEtag (self: *const R2ObjectBody) []const u8 {
    return getStringFree(getObjectValue(self.id, "httpEtag"));
  }

  pub fn uploaded (self: *const R2ObjectBody) Date {
    return Date.init(getObjectValue(self.id, "uploaded"));
  }

  pub fn httpMetadata (self: *const R2ObjectBody) R2HTTPMetadata {
    return R2HTTPMetadata.init(getObjectValue(self.id, "httpMetadata"));
  }

  pub fn customMetadata (self: *const R2ObjectBody) Record {
    return Record.init(getObjectValue(self.id, "customMetadata"));
  }

  pub fn range (self: *const R2ObjectBody) R2Range {
    const r2range = Object.init(getObjectValue(self.id, "range"));
    defer r2range.free();
    return R2Range.fromObject(r2range);
  }

  pub fn writeHttpMetadata (self: *const R2ObjectBody, headers: Headers) void {
    const httpMeta = self.httpMetadata();
    httpMeta.writeHttpMetadata(headers);
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1124
pub const R2Objects = struct {
  pub fn objects (self: *const R2Objects) ListR2Objects {
    return ListR2Objects.init(getObjectValue(self.id, "objects"));
  }

  pub fn truncated (self: *const R2ObjectBody) bool {
    const trunc = getObjectValue(self.id, "truncated");
    return trunc == True;
  }

  pub fn cursor (self: *const R2Objects) []const u8 {
    return getStringFree(getObjectValue(self.id, "cursor"));
  }

  pub fn delimitedPrefixes (self: *const R2Objects) ListDelimitedPrefixes {
    return ListDelimitedPrefixes.init(getObjectValue(self.id, "delimitedPrefixes"));
  }

  pub const ListR2Objects = struct {
    arr: Array,
    pos: u32 = 0,
    len: u32,

    pub fn init (jsPtr: u32) ListR2Objects {
      const arr = Array.init(jsPtr);
      return ListR2Objects{
        .arr = arr,
        .len = arr.length(),
      };
    }

    pub fn free (self: *const ListR2Objects) void {
      self.arr.free();
    }

    pub fn next (self: *ListR2Objects) ?R2Object {
      if (self.pos == self.len) return null;
      const r2object = self.arr.getType(R2Object, self.pos);
      self.pos += 1;
      return r2object;
    }
  };

  pub const ListDelimitedPrefixes = struct {
    arr: Array,
    pos: u32 = 0,
    len: u32,

    pub fn init (jsPtr: u32) ListDelimitedPrefixes {
      const arr = Array.init(jsPtr);
      return ListDelimitedPrefixes{
        .arr = arr,
        .len = arr.length(),
      };
    }

    pub fn free (self: *const ListDelimitedPrefixes) void {
      self.arr.free();
    }

    pub fn next (self: *ListDelimitedPrefixes) ?String {
      if (self.pos == self.len) return null;
      const str = self.arr.getType(String, self.pos);
      self.pos += 1;
      return str;
    }
  };
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1040
pub const R2Conditional = struct {
  etagMatches: ?[]const u8 = null,
  etagDoesNotMatch: ?[]const u8 = null,
  uploadedBefore: ?Date = null,
  uploadedAfter: ?Date = null,
};

pub const OnlyIf = union(enum) {
  r2Conditional: *const R2Conditional,
  headers: *const Headers,
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1050
pub const R2GetOptions = struct {
  onlyIf: ?OnlyIf = null,
  range: ?R2Range = null,
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1131
pub const R2PutOptions = struct {
  httpMetadata: ?R2PutOptionsHttpMetadata,
  customMetadata: ?Record,
  md5: ?R2PutOptionsMd5,

  pub const R2PutOptionsHttpMetadata = union(enum) {
    r2HTTPMetadata: R2HTTPMetadata,
    headers: Headers,
  };

  pub const R2PutOptionsMd5 = union(enum) {
    string: String,
    text: []const u8,
    arrayBuffer: ArrayBuffer,
    bytes: []const u8,
  };
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L948
pub const R2ListOptions = struct {
  limit: u16 = 1_000,
  prefix: ?[]const u8 = null,
  jsPrefix: ?*const String = null,
  cursor: ?[]const u8 = null,
  jsCursor: ?*const String = null,
  delimiter: ?[]const u8 = null,
  jsDelimiter: ?*const String = null,
  includeHttpMetadata: bool = false,
  includeCustomMetadata: bool = false,

  pub fn toObject (self: *const R2ListOptions) Object {
    const obj = Object.new();

    obj.setNum("limit", u16, self.limit);
    if (self.prefix != null) obj.setText("prefix", self.prefix.?);
    if (self.jsPrefix != null) obj.set("prefix", &self.jsPrefix.?);
    if (self.cursor != null) obj.setText("cursor", self.cursor.?);
    if (self.jsCursor != null) obj.set("cursor", &self.jsCursor.?);
    if (self.delimiter != null) obj.setText("delimiter", self.delimiter.?);
    if (self.jsDelimiter != null) obj.set("delimiter", &self.jsDelimiter.?);
    if (self.includeHttpMetadata or self.includeCustomMetadata) {
      const arr = Array.new();
      defer arr.free();
      if (self.includeHttpMetadata) arr.pushString("httpMetadata");
      if (self.includeCustomMetadata) arr.pushString("customMetadata");
      obj.set("include", &arr);
    }

    return obj;
  }
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
    const func = AsyncFunction.init(getObjectValue(self.id, "head"));
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
    const func = AsyncFunction.init(getObjectValue(self.id, "get"));
    defer func.free();
    // prep the args
    const args = Array.new();
    defer args.free();
    args.push(&keyStr);
    args.push(&opts);

    const result = func.callArgs(&args);
    if (result <= DefaultValueSize) return null;
    const hasBody = object.hasObject("body");
    if (hasBody) return R2GetResponse{ .r2objectBody = R2ObjectBody.init(result) };
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
    const func = AsyncFunction.init(getObjectValue(self.id, "put"));
    defer func.free();
    // prep the args
    const args = Array.new();
    defer args.free();
    args.push(&keyStr);
    args.pushID(val);
    args.push(&opts);

    _ = func.callArgs(&args);
  }

  pub fn delete (self: *const R2Bucket, key: []const u8) void {
    // prep the string
    const str = String.new(key);
    defer str.free();
    // grab the function
    const func = AsyncFunction.init(getObjectValue(self.id, "delete"));
    defer func.free();

    _ = func.callArgs(&str);
  }

  pub fn list (self: *const R2Bucket, options: R2ListOptions) R2Objects {
    // grab options
    const opts = options.toObject();
    defer opts.free();
    // grab the function
    const func = AsyncFunction.init(getObjectValue(self.id, "list"));
    defer func.free();

    return R2Objects.init(func.callArgs(&opts));
  }
};
