const jsFree = @import("common.zig").jsFree;

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L655
// TODO: add "isField" and "isFile"
pub const FormEntry = union(enum) {
  field: []const u8,
  file: File,
};

pub const File = struct {
  id: u32,
  size: usize,
  last_modified: u64,

  // fn type() []u8 {

  // }

  // fn bytes() []u8 {

  // }
};

pub const FormData = struct {
  id: u32,

  pub fn init (ptr: u32) FormData {
    return FormData{ .id = ptr };
  }

  pub fn free (self: *const FormData) void {
    jsFree(self.id);
  }

  // fn append(name: []u8, value: []u8) void {

  // }

  // TODO: append(name: []u8, value: Blob, filename?: []u8): void;

  // fn delete(name: []u8) void {

  // }

  // fn get(name: []u8) File | []u8 | null {

  // }

  // TODO: fn getAll(name: []u8) [](File | []u8) {

  // }

  // fn has(name: []u8) bool {

  // }

  // set(name: []u8, value: Blob, filename?: []u8): void;
  // fn (name: []u8, value: []u8) void {

  // }

  // fn entries() {}

  // fn keys() [][]u8 {}

  // fn values() [](File | []u8)
};
