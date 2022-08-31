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
    const first = stmt.bind(&args).first(null);
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
    const all = stmt.bind(&args).all();
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

pub fn d1RawHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const db = ctx.env.d1("TEST_DB") orelse {
      ctx.throw(500, "Could not find \"TEST_DB\"");
      return;
    };
    defer db.free();

    // prepare statement
    const stmt = db.prepare("SELECT CompanyName FROM Customers");
    defer stmt.free();
    const raw = stmt.raw();
    defer raw.free();

    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .objectID = raw.id },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn d1RunHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const db = ctx.env.d1("TEST_DB") orelse {
      ctx.throw(500, "Could not find \"TEST_DB\"");
      return;
    };
    defer db.free();

    // prepare statement
    const args = Array.new();
    defer args.free();
    args.pushNum(u8, 69);
    args.pushText("S2Maps");
    args.pushText("CTO");
    const stmt = db.prepare("INSERT INTO Customers (CustomerID, CompanyName, ContactName) VALUES (?, ?, ?)");
    defer stmt.free();
    const run = stmt.bind(&args).run();
    defer run.free();

    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .objectID = run.id },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn d1BatchHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const db = ctx.env.d1("TEST_DB") orelse {
      ctx.throw(500, "Could not find \"TEST_DB\"");
      return;
    };
    defer db.free();

    // prepare customers
    const cust1 = createCustomer(69, "S2Maps", "CTO");
    defer cust1.free();
    const cust2 = createCustomer(70, "Hi", "OTC");
    defer cust2.free();
    const cust3 = createCustomer(71, "Three", "Name");
    defer cust3.free();

    // prepare statement
    const stmt = db.prepare("INSERT INTO Customers (CustomerID, CompanyName, ContactName) VALUES (?, ?, ?)");
    defer stmt.free();

    const batch = db.batch(&.{
        stmt.bind(&cust1),
        stmt.bind(&cust2),
        stmt.bind(&cust3),
    });
    defer batch.free();

    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .objectID = batch.id },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn createCustomer (id: u8, name: []const u8, contact: []const u8) Array {
    const args = Array.new();
    args.pushNum(u8, id);
    args.pushText(name);
    args.pushText(contact);

    return args;
}

pub fn d1ExecHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const db = ctx.env.d1("TEST_DB") orelse {
      ctx.throw(500, "Could not find \"TEST_DB\"");
      return;
    };
    defer db.free();

    const exec = db.exec("CREATE TABLE Users (id INT PRIMARY KEY, name TEXT, password TEXT);");
    defer exec.free();

    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .object = &exec },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}
