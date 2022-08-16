const jsFree = @import("../bindings/common.zig").jsFree;

pub const MAX_SIZE = 25 * 1000 * 1000; // 25MiB

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L890
// ? ArrayBufferView
pub const PutValue = union(enum) {
  string: String,
  arrayBuffer: ArrayBuffer,
  readableStream: ReadableStream,
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L960
pub const PutOptions = struct {
  expiration: ?u64 = null, // secondsSinceEpoch
  expirationTtl: ?u64 = null // secondsFromNow
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L948
pub const ListOptions = struct {
  limit: u16 = 1000,
  prefix: ?[]u8 = null,
  cursor: ?[]u8 = null

  // TODO: build a JS object, add self values and return the object ptr
  toObject (self: *const ListOptions) Object {
    const obj = Object.new();
    obj.setNum("limit", self.limit);
    if (self.prefix != null) obj.setString("prefix", self.prefix.?);
    if (self.cursor != null) obj.setString("cursor", self.cursor.?);

    return obj;
  }
};

pub const ListResponse = struct {
  id: u32,
  
  pub fn init (id: u32) ListResponse {
    return ListResponse{ .id = id };
  }

  pub fn count () usize {

  }

  pub fn get (index: usize) ListKey {

  }

  pub fn cursor () []u8 {

  }

  pub fn listComplete () bool {

  }

  pub const ListKey = struct {
    id: u32,

    pub fn name () []u8 {

    }

    pub fn metadata (comptime T: type) ParseError(T)!T {

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


  pub fn putString (key: []const u8, value: []const u8) void {

  }

  pub fn putJSON (key: []const u8, comptime json: type, json: anytype) void {

  }

  pub fn putStream (key: []const u8, readableStream: *const ReadableStream) void {

  }

  pub fn putBlob (key: []const u8, blob: *const Blob) void {

  }

  pub fn putBytes (key: []const u8, value: []u8) void {

  }

  pub fn putWithMetadataString (key: []const u8, value: []const u8, comptime metadata: type) void {

  }

  pub fn putWithMetadataJSON (key: []const u8, comptime T: type, json: anytype, comptime metadata: type) void {

  }

  pub fn putWithMetadataStream (key: []const u8, readableStream: *const ReadableStream, comptime metadata: type) void {

  }

  pub fn putWithMetadataBlob (key: []const u8, blob: Blob, comptime metadata: type) void {

  }

  pub fn putWithMetadataBytes (key: []const u8, value: []u8, comptime metadata: type) void {

  }

  pub fn getString (key: []const u8, cacheTtl: ?u64) []const u8 {

  }

  pub fn getJSON (key: []const u8, comptime T: type, cacheTtl: ?u64) ParseError(T)!T {

  }

  pub fn getBytes (key: []const u8, cacheTtl: ?u64) []u8 {

  }

  pub fn getStream (key: []const u8, cacheTtl: ?u64) ReadableStream {

  }

  pub fn getWithMetadataString (key: []const u8, cacheTtl: ?u64) []const u8 {

  }

  pub fn getWithMetadataJSON (key: []const u8, comptime T: type, cacheTtl: ?u64) ParseError(T)!T {

  }

  pub fn getWithMetadataBytes (key: []const u8, cacheTtl: ?u64) []u8 {

  }

  pub fn getWithMetadataStream (key: []const u8, cacheTtl: ?u64) ReadableStream {

  }

  pub fn delete (key: []const u8) void {

  }

  pub fn list (options: ?ListOptions) ListResponse {

  }
};
