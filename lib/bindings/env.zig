const getStringFree = @import("string.zig").getStringFree;
const getObjectValue = @import("object.zig").getObjectValue;
const common = @import("common.zig");
const jsFree = common.jsFree;
const DefaultValueSize = common.DefaultValueSize;
const KVNamespace = @import("../apis/kv.zig").KVNamespace;
const R2Bucket = @import("../apis/r2.zig").R2Bucket;
const D1Database = @import("../apis/d1.zig").D1Database;

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
    return getStringFree(strPtr);
  }

  pub fn secret (self: *const Env, name: []const u8) ?[]const u8 {
    const strPtr = getObjectValue(self.id, name);
    if (strPtr <= DefaultValueSize) return null;
    return getStringFree(strPtr);
  }

  pub fn d1 (self: *const Env, name: []const u8) ?D1Database {
    const d1Ptr = getObjectValue(self.id, name);
    if (d1Ptr <= DefaultValueSize) return null;
    return D1Database.init(d1Ptr);
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
