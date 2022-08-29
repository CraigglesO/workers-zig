const std = @import("std");
const allocator = std.heap.page_allocator;

const worker = @import("workers-zig");
const FetchContext = worker.FetchContext;
const Response = worker.Response;
const String = worker.String;
const Headers = worker.Headers;
const Object = worker.Object;
const ArrayBuffer = worker.ArrayBuffer;
const Array = worker.Array;
const Undefined = worker.Undefined;
const True = worker.True;
const False = worker.False;

const MetaTest = struct {
    name: []const u8 = "",
    input: u32 = 0,
};

pub fn r2StreamHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const r2 = ctx.env.r2("TEST_BUCKET") orelse {
      ctx.throw(500, "Could not find \"TEST_BUCKET\"");
      return;
    };
    defer r2.free();
    // put
    const putRes = r2.put("key", .{ .text = "value" }, .{});
    defer putRes.free();
    // get
    const getRes = r2.get("key", .{});
    defer getRes.free();
    const stream = switch (getRes) {
      .r2objectBody => |bod| bod.body(),
      else => {
        ctx.throw(500, "Could not get body");
        return {};
      }
    };
    defer stream.free();
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .stream = &stream },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn r2TextHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const r2 = ctx.env.r2("TEST_BUCKET") orelse {
      ctx.throw(500, "Could not find \"TEST_BUCKET\"");
      return;
    };
    defer r2.free();
    // put
    const putRes = r2.put("key", .{ .text = "value" }, .{});
    defer putRes.free();
    // get
    const getRes = r2.get("key", .{});
    defer getRes.free();
    const text = switch (getRes) {
      .r2objectBody => |bod| bod.text(),
      else => {
        ctx.throw(500, "Could not get body");
        return {};
      },
    };
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .text = text },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn r2StringHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const r2 = ctx.env.r2("TEST_BUCKET") orelse {
      ctx.throw(500, "Could not find \"TEST_BUCKET\"");
      return;
    };
    defer r2.free();
    // put
    const inStr = String.new("value");
    defer inStr.free();
    const putRes = r2.put("key", .{ .string = &inStr }, .{});
    defer putRes.free();
    // get
    const getRes = r2.get("key", .{});
    defer getRes.free();
    const string = switch (getRes) {
      .r2objectBody => |bod| bod.string(),
      else => {
        ctx.throw(500, "Could not get body");
        return {};
      },
    };
    defer string.free();
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .string = &string },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}
