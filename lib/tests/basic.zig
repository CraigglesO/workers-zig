const std = @import("std");
const allocator = std.heap.page_allocator;

// usingnamespace @import("workers-zig");
const workersZig = @import("workers-zig");
const FetchContext = workersZig.FetchContext;
const Response = workersZig.Response;
const String = workersZig.String;
const Headers = workersZig.Headers;

// usingnamespace @import("workers-zig");

// https://github.com/ziglang/zig/issues/3160
// until @asyncCall WASM support is implemented we use a double-up function
pub export fn basicFetch (ctxID: u32) void {
    // build the ctx
    const ctx = FetchContext.init(ctxID) catch {
        const err = String.new("Unable to prepare a FetchContext.");
        defer err.free();
        err.throw();
        return undefined;
    };
    // build / keep a frame alive
    const frame = allocator.create(@Frame(basicHandler)) catch {
        ctx.throw(500, "Unable to prepare the kvStringHandler handler.");
        return undefined;
    };
    frame.* = async basicHandler(ctx);
    // tell the context about the frame for later destruction
    ctx.frame.* = frame;
}
fn basicHandler (ctx: *FetchContext) callconv(.Async) void {
    // get body from request
    const text = await async ctx.req.text() orelse return ctx.throw(500, "Failed to get body.");
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
