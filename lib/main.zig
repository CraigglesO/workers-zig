const std = @import("std");
const allocator = std.heap.page_allocator;

pub usingnamespace @import("apis/main.zig");
pub usingnamespace @import("bindings/main.zig");
pub usingnamespace @import("http/main.zig");
pub usingnamespace @import("worker/main.zig");

// ** EXPORTS **

// ALLOCATION
pub export fn alloc (size: usize) ?[*]u8 {
    const data = allocator.alloc(u8, size) catch return undefined;
    return data.ptr;
}
pub export fn allocSentinel (size: usize) ?[*:0]u8 {
    const data = allocator.allocSentinel(u8, size, 0) catch return undefined;
    return data.ptr;
}
pub export fn free (ptr: [*]u8) void {
    allocator.destroy(ptr);
}

// FUNCTION / ASYNC FUNCTION
pub export fn wasmResume (frame: *anyopaque) callconv(.C) void {
    resume @ptrCast(anyframe, @alignCast(4, frame));
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
    // const ctx = try FetchContext.init(ctxID);
    // defer ctx.free();
}

// ? PART 1
// * KV
// * R2

// * schedule fn
// * testings
// * build skeleton

// * share
// * DOCS
// * streams (all the rest)
// * HEADERS + ITERATOR
// * finish CF
// * D1
// * DOs
