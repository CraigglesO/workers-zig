const ReadableStream = @import("streams/readable.zig").ReadableStream;
const String = @import("string.zig").String;
const Object = @import("object.zig").Object;
const jsStringify = @import("object.zig").jsStringify;
const ArrayBuffer = @import("arraybuffer.zig").ArrayBuffer;
const Blob = @import("blob.zig").Blob;
const URLSearchParams = @import("url.zig").URLSearchParams;
const FormData = @import("formData.zig").FormData;
const common = @import("common.zig");
const jsFree = common.jsFree;
const Null = common.Null;

pub const BodyInit = union(enum) {
  stream: *const ReadableStream,
  string: *const String,
  text: []const u8,
  object: *const Object,
  objectID: u32,
  arrayBuffer: *const ArrayBuffer,
  bytes: []const u8,
  blob: *const Blob,
  urlSearchParams: *const URLSearchParams,
  formData: *const FormData,
  none,

  pub fn toID (self: *const BodyInit) u32 {
    switch (self.*) {
      .stream => |rs| return rs.id,
      .string => |s| return s.id,
      .text => |t| return String.new(t).id,
      .object => |o| return o.stringify().id,
      .objectID => |oid| return jsStringify(oid),
      .arrayBuffer => |ab| return ab.id,
      .bytes => |b| return ArrayBuffer.new(b).id,
      .blob => |blob| return blob.id,
      .urlSearchParams => |params| return params.id,
      .formData => |formData| return formData.id,
      .none => return Null,
    }
  }

  pub fn free (self: *const BodyInit, id: u32) void {
    switch (self.*) {
      .text => jsFree(id),
      .object => jsFree(id),
      .objectID => jsFree(id),
      .bytes => jsFree(id),
      else => {},
    }
  }
};
