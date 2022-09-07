const std = @import("std");
const allocator = std.heap.page_allocator;

const worker = @import("workers-zig");
const fetch = worker.fetch;
const FetchContext = worker.FetchContext;
const Request = worker.Request;
const Response = worker.Response;
const String = worker.String;
const Headers = worker.Headers;

pub fn fetchHandler (ctx: *FetchContext) callconv(.Async) void {
    // fetch from local
    const localRes = fetch(.{ .text = "http://127.0.0.1:8787/kv/text" }, null);
    defer localRes.free();

    ctx.send(&localRes);
}
