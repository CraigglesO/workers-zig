const jsFree = @import("../common.zig").jsFree;

// 
pub const WritableStream = struct {
  id: u32,

  pub fn init (ptr: u32) WritableStream {
    return WritableStream{ .id = ptr };
  }

  pub fn free (self: WritableStream) void {
    jsFree(self.id);
  }

  fn from(id: u32) void {
    id = id;
  }
};

// call an object fn callObject(objectID: u32, )
// get a string input from an object as number/string

const File = struct {
  name: []u8,
  size: u64
};

pub const FormEntry = enum {
  field,
  file
};

// // if string returned
// const FormUnion = union(FormEntry) { field: []u8, file: File };
// // if file returned
// const result = FormUnion{ .field = "example" };