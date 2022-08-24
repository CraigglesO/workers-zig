const getString = @import("string.zig").getString;
const getObjectValue = @import("object.zig").getObjectValue;
const common = @import("common.zig");
const jsFree = common.jsFree;
const DefaultValueSize = common.DefaultValueSize;
const KVNamespace = @import("../apis/kv.zig").KVNamespace;
const R2Bucket = @import("../apis/r2.zig").R2Bucket;

pub const Env = struct {
  id: u32,
  
  pub fn init (ptr: u32) Env {
    return Env{ .id = ptr };
  }

  pub fn free (self: *const Env) void {
    jsFree(self.id);
  }

  pub fn key (self: *const Env, name: []const u8) ?[]const u8 {
    const strPtr = getObjectValue(self.id, name);
    if (strPtr <= DefaultValueSize) return null;
    defer jsFree(strPtr);
    return getString(strPtr);
  }

  pub fn secret (self: *const Env, name: []const u8) ?[]const u8 {
    const strPtr = getObjectValue(self.id, name);
    if (strPtr <= DefaultValueSize) return null;
    defer jsFree(strPtr);
    return getString(strPtr);
  }

  pub fn d1 () void {

  }

  pub fn durableObject () void {

  }

  pub fn kv (self: *const Env, name: []const u8) ?KVNamespace {
    const kvPtr = getObjectValue(self.id, name);
    if (kvPtr <= DefaultValueSize) return null;
    return KVNamespace.init(kvPtr);
  }

  pub fn r2 (self: *const Env, name: []const u8) ?R2Bucket {
    const r2Ptr = getObjectValue(self.id, name);
    if (r2Ptr <= DefaultValueSize) return null;
    return R2Bucket.init(r2Ptr);
  }
};
