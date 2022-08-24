const ReadableStream = @import("streams/readable.zig").ReadableStream;
const String = @import("string.zig").String;
const ArrayBuffer = @import("arraybuffer.zig").ArrayBuffer;
const Blob = @import("blob.zig").Blob;
const URLSearchParams = @import("url.zig").URLSearchParams;
const FormData = @import("formData.zig").FormData;
const Null = @import("common.zig").Null;

pub const BodyInit = union(enum) {
  stream: *const ReadableStream,
  string: *const String,
  text: []const u8,
  arrayBuffer: *const ArrayBuffer,
  bytes: []const u8,
  blob: *const Blob,
  urlSearchParams: *const URLSearchParams,
  formData: *const FormData,
  none,

  pub fn toID (self: *const BodyInit) u32 {
    var bodyID: u32 = Null;
    switch (self.*) {
      .stream => |rs| bodyID = rs.id,
      .string => |s| bodyID = s.id,
      .text => |t| bodyID = String.new(t).id,
      .arrayBuffer => |ab| bodyID = ab.id,
      .bytes => |b| bodyID = ArrayBuffer.new(b).id,
      .blob => |blob| bodyID = blob.id,
      .urlSearchParams => |params| bodyID = params.id,
      .formData => |formData| bodyID = formData.id,
      .none => {},
    }

    return bodyID;
  }
};
