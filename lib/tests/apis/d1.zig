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

const Customer = struct {
    CustomerID: u32 = "",
    CustomerID: ?[]const u8 = null,
    ContactName: ?[]const u8 = null,
};

pub fn d1FirstHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const db = ctx.env.d1("TEST_DB") orelse {
      ctx.throw(500, "Could not find \"TEST_DB\"");
      return;
    };
    defer db.free();

    // prepare statement
    const args = Array.new();
    defer args.free();
    args.pushNum(u8, 1);
    const stmt = db.prepare("SELECT CompanyName FROM Customers WHERE CustomerID = ?");
    defer stmt.free();
    const first = stmt.bind(args).first(null);
    defer first.free();

    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .object = &first },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn d1AllHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const db = ctx.env.d1("TEST_DB") orelse {
      ctx.throw(500, "Could not find \"TEST_DB\"");
      return;
    };
    defer db.free();

    // prepare statement
    const args = Array.new();
    defer args.free();
    args.pushNum(u8, 1);
    const stmt = db.prepare("SELECT CompanyName FROM Customers WHERE CustomerID = ?");
    defer stmt.free();
    const all = stmt.bind(args).all();
    defer all.free();

    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .objectID = all.id },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}
