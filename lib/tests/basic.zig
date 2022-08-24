const std = @import("std");
const allocator = std.heap.page_allocator;

const workersZig = @import("workers-zig");
const FetchContext = workersZig.FetchContext;
const Response = workersZig.Response;
const String = workersZig.String;
const Headers = workersZig.Headers;

pub fn basicHandler (ctx: *FetchContext) void {
    // get body from request
    const text = ctx.req.text() orelse return ctx.throw(500, "Failed to get body.");
    defer allocator.free(text);
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.set("Content-Type", "text/plain");
    // body
    const body = String.new(text);
    defer body.free();
    // response
    const res = Response.new(
        .{ .string = &body },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}
