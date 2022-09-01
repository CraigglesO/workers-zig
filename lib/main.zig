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

// ? PART 1
// * DOCS
// * build skeleton
// * share

// ? PART 2
// * R2 tests: R2ListOptions, R2PutOptions, R2GetOptions, httpmetadata/custom + write->headers check
// * D1 tests: check next()s are working
// * req/res tests
// * new method of managing js heap so that after a request the heap is gaurenteed cleaned up
// * finish crypto
// * zigFunction with input args (for lone bindings like string)
// * allow user to set own zig + js
// * add tests for all basic bindings
// * streams (all the rest)
// * HEADERS + ITERATOR
// * finish CF
// * DOs
