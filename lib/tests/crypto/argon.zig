const std = @import("std");
const argon2 = std.crypto.pwhash.argon2;
const strHash = argon2.strHash;
const strVerify = argon2.strVerify;
const allocator = std.heap.page_allocator;

const worker = @import("workers-zig");
const FetchContext = worker.FetchContext;
const Response = worker.Response;
const String = worker.String;
const Headers = worker.Headers;

const salt = "somesalt";

pub fn argonHashHandler (ctx: *FetchContext) callconv(.Async) void {
    // get body from request
    const password = ctx.req.text() orelse return ctx.throw(500, "Failed to get body.");
    defer allocator.free(password);

    // hash the password
    var buf: [128]u8 = undefined;
    const hash = strHash(
        password,
        .{
            .allocator = allocator,
            .params = .{ .t = 3, .m = 32, .p = 1, .secret = salt },
            .mode = argon2.Mode.argon2i,
        },
        &buf,
    ) catch "";

    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // body
    const body = String.new(hash);
    defer body.free();
    // response
    const res = Response.new(
        .{ .string = &body },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}
// try strVerify(hash, password, .{ .allocator = allocator });
