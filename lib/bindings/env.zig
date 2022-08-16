const getString = @import("string.zig").getString;
const getObjectValue = @import("object.zig").getObjectValue;
const jsFree = @import("common.zig").jsFree;

pub const Env = struct {
  id: u32,
  
  pub fn init (ptr: u32) Env {
    return Env{ .id = ptr };
  }

  pub fn free (self: *const Env) void {
    jsFree(self.id);
  }

  pub fn key (self: *const Env, name: []const u8) []const u8 {
    const strPtr = getObjectValue(self.id, name);
    return getString(strPtr);
  }

  pub fn secret (self: *const Env, name: []const u8) []const u8 {
    const strPtr = getObjectValue(self.id, name);
    return getString(strPtr);
  }

  pub fn d1 () void {

  }

  pub fn durableObject () void {

  }

  pub fn kv () void {

  }

  pub fn r2 () void {

  }
};
