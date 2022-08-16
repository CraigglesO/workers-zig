const std = @import("std");
const jsAsync = @import("bindings/function.zig").jsAsync;
const AsyncFunction = @import("bindings/function.zig").AsyncFunction;
const Context = @import("worker/fetch.zig").Context;
const HandlerFn = @import("worker/fetch.zig").HandlerFn;
const Response = @import("bindings/response.zig").Response;
const ResponseInit = @import("bindings/response.zig").ResponseInit;
const String = @import("bindings/string.zig").String;
const Headers = @import("bindings/headers.zig").Headers;
const allocator = std.heap.page_allocator;

// ** EXPORTS **

// ALLOCATION
export fn alloc(size: usize) ?[*]u8 {
    const data = allocator.alloc(u8, size) catch return undefined;
    return data.ptr;
}
export fn allocSentinel(size: usize) ?[*:0]u8 {
    const data = allocator.allocSentinel(u8, size, 0) catch return undefined;
    return data.ptr;
}
export fn free(ptr: [*]u8) void {
    allocator.destroy(ptr);
}

// FUNCTION / ASYNC FUNCTION
export fn wasmResume(frame: *anyopaque) callconv(.C) void {
    resume @ptrCast(anyframe, @alignCast(4, frame));
}

// NOTE:
// https://github.com/ziglang/zig/issues/3160
// until @asyncCall WASM support is implemented we use a double-up function
export fn basicFetch(ctxID: u32) void {
    // build the ctx
    const ctx = Context.init(ctxID) catch {
        // TODO: throw a js error
        return undefined;
    };
    // build / keep a frame alive
    const frame = allocator.create(@Frame(basicHandler)) catch {
        // TODO: throw a js error
        return undefined;
    };
    frame.* = async basicHandler(ctx);
    // tell the context about the frame for later destruction
    ctx.frame.* = frame;
}
fn basicHandler(ctx: *Context) callconv(.Async) void {
    // get body from request
    // const text = await async ctx.req.text() orelse "failed";
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

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}

// ? PART 1
// * RESPONSE
// * HEADERS + ITERATOR
// * streams (read, write, transform)
// * cache
// * KV
// * R2
// * schedule fn
// * DOCS
