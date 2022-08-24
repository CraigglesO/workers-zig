const std = @import("std");
const allocator = std.heap.page_allocator;

pub usingnamespace @import("apis/main.zig");
pub const bindings = @import("bindings/main.zig");
usingnamespace bindings;
pub usingnamespace @import("http/main.zig");
pub const worker = @import("worker/main.zig");
usingnamespace worker;

// ** EXPORTS **

// ALLOCATION
pub export fn alloc (size: usize) ?[*]u8 {
    const data = allocator.alloc(u8, size) catch return null;
    return data.ptr;
}
pub export fn allocSentinel (size: usize) ?[*:0]u8 {
    const data = allocator.allocSentinel(u8, size, 0) catch return null;
    return data.ptr;
}
pub export fn free (ptr: [*]u8) void {
    allocator.destroy(ptr);
}

// FUNCTION / ASYNC FUNCTION
pub export fn wasmResume (frame: *anyopaque) callconv(.C) void {
    resume @ptrCast(anyframe, @alignCast(4, frame));
}

pub export fn handleRequest (routerPtr: *anyopaque, ctxID: u32) void {
    // Grab the router
    const router = @ptrCast(*worker.Router, @alignCast(4, routerPtr));
    // build the fetchContext
    const ctx = worker.FetchContext.init(ctxID) catch {
      bindings.String.new("Unable to prepare a FetchContext.").throw();
      return;
    };
    const frame = allocator.create(@Frame(_handleRequest)) catch {
        ctx.throw(500, "Unable to prepare a frame.");
        return undefined;
    };
    frame.* = async _handleRequest(router, ctx);
    // tell the context about the frame for later destruction
    ctx.frame.* = frame;
}

fn _handleRequest (router: *worker.Router, ctx: *worker.FetchContext) callconv(.Async) void {
    router.handleRequest(ctx);
}

// ? PART 1
// * Use fetch function
// * KV (getStream test)
// * Cache tests
// * R2

// * schedule fn
// * build skeleton
// * DOCS

// * share

// * add tests for all basic bindings
// * streams (all the rest)
// * HEADERS + ITERATOR
// * finish CF
// * D1
// * DOs
