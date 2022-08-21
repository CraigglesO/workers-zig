const ReadableStream = @import("streams/readable.zig").ReadableStream;
const String = @import("string.zig").String;
const ArrayBuffer = @import("arraybuffer.zig").ArrayBuffer;
const Blob = @import("blob.zig").Blob;
const URLSearchParams = @import("url.zig").URLSearchParams;
const FormData = @import("formData.zig").FormData;
const Null = @import("common.zig").Null;

pub const BodyInit = union(enum) {
  readableStream: *const ReadableStream,
  string: *const String,
  arrayBuffer: *const ArrayBuffer,
  blob: *const Blob,
  urlSearchParams: *const URLSearchParams,
  formData: *const FormData,
  none,

  pub fn getID (self: *const BodyInit) u32 {
    var bodyID: u32 = Null;
    switch (self.*) {
      .readableStream => |rs| bodyID = rs.id,
      .string => |s| bodyID = s.id,
      .arrayBuffer => |ab| bodyID = ab.id,
      .blob => |blob| bodyID = blob.id,
      .urlSearchParams => |params| bodyID = params.id,
      .formData => |formData| bodyID = formData.id,
      .none => {},
    }

    return bodyID;
  }
};
