const ReadableStream = @import("streams/readable.zig").ReadableStream;
const String = @import("string.zig").String;
const ArrayBuffer = @import("arraybuffer.zig").ArrayBuffer;
const Blob = @import("blob.zig").Blob;
const URLSearchParams = @import("url.zig").URLSearchParams;
const FormData = @import("formData.zig").FormData;

pub const BodyInit = union(enum) {
  readableStream: *const ReadableStream,
  string: *const String,
  arrayBuffer: *const ArrayBuffer,
  blob: *const Blob,
  urlSearchParams: *const URLSearchParams,
  formData: *const FormData,
  none
};
