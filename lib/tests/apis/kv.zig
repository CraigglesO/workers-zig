const std = @import("std");
const allocator = std.heap.page_allocator;

const workersZig = @import("workers-zig");
const FetchContext = workersZig.FetchContext;
const Response = workersZig.Response;
const String = workersZig.String;
const Headers = workersZig.Headers;
const Object = workersZig.Object;
const ArrayBuffer = workersZig.ArrayBuffer;

pub fn kvStringHandler (ctx: *FetchContext) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();
    // create a js string to use
    const jsStr = String.new("value");
    defer jsStr.free();
    kv.put("key", .{ .string = &jsStr }, .{});
    const text = kv.getString("key", .{}) orelse {
        ctx.throw(500, "Could not find KV key's value");
        return;
    };
    defer text.free();
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.set("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .string = &text },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvTextHandler (ctx: *FetchContext) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();
    kv.put("key2", .{ .text = "value2" }, .{});
    const text = kv.getText("key2", .{}) orelse {
        ctx.throw(500, "Could not find KV key's value");
        return;
    };
    defer allocator.free(text);
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.set("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .text = text },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

const TestObj = struct {
    a: u32,
    b: []const u8,

    pub fn toObject (self: *const TestObj) Object {
        const obj = Object.new();
        obj.setNum("a", @intToFloat(f64, self.a));
        obj.setString("b", self.b);

        return obj;
    }
};

pub fn kvObjectHandler (ctx: *FetchContext) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();

    // build the object
    const obj = TestObj{ .a = 1, .b = "test" };
    const jsObj = obj.toObject();
    defer jsObj.free();
    kv.put("obj", .{ .object = &jsObj }, .{});
    const getObj = kv.getObject("obj", .{}) orelse {
        ctx.throw(500, "Could not find KV key's value");
        return;
    };
    defer getObj.free();
    // get obj as string
    const body = getObj.stringify();
    defer body.free();
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.set("Content-Type", "application/json");
    // response
    const res = Response.new(
        .{ .string = &body },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvJSONHandler (ctx: *FetchContext) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();

    // build the object
    const obj = TestObj{ .a = 1, .b = "test" };
    const jsObj = obj.toObject();
    defer jsObj.free();
    kv.put("obj", .{ .object = &jsObj }, .{});
    const getObj = kv.getJSON(TestObj, "obj", .{}) orelse {
        ctx.throw(500, "Could not find KV key's value");
        return;
    };
    defer allocator.free(getObj.b);
    // defer getObj.free();
    // const testObj = getObj.parse(TestObj) catch {
    //     ctx.throw(500, "Could not convert object to \"TestObj\"");
    //     return;
    // };
    defer allocator.free(getObj.b);
    const getObjJS = getObj.toObject();
    defer getObjJS.free();
    // get obj as string
    const body = getObjJS.stringify();
    defer body.free();
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.set("Content-Type", "application/json");
    // response
    const res = Response.new(
        .{ .string = &body },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvArraybufferHandler (ctx: *FetchContext) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();

    // build the object
    const bytes = [_]u8{ 0, 1, 2, 3};
    const ab = ArrayBuffer.new(bytes[0..]);
    defer ab.free();
    kv.put("ab", .{ .arrayBuffer = &ab }, .{});
    const getAB = kv.getArrayBuffer("ab", .{}) orelse {
        ctx.throw(500, "Could not find KV key's value");
        return;
    };
    defer getAB.free();
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.set("Content-Type", "application/json");
    // response
    const res = Response.new(
        .{ .arrayBuffer = &getAB },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvStreamHandler (ctx: *FetchContext) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();

    // build the object
    const arr = [_]u8{ 0, 1, 2, 3};
    kv.put("stream", .{ .bytes = arr[0..] }, .{});
    const getStream = kv.getStream("stream", .{}) orelse {
        ctx.throw(500, "Could not find KV key's value");
        return;
    };
    defer getStream.free();
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.set("Content-Type", "application/json");
    // response
    const res = Response.new(
        .{ .stream = &getStream },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvBytesHandler (ctx: *FetchContext) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();

    // build the object
    const arr = [_]u8{ 0, 1, 2, 3};
    kv.put("bytes", .{ .bytes = arr[0..] }, .{});
    const getBytes = kv.getBytes("bytes", .{}) orelse {
        ctx.throw(500, "Could not find KV key's value");
        return;
    };
    defer allocator.free(getBytes);
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.set("Content-Type", "application/json");
    // response
    const res = Response.new(
        .{ .bytes = getBytes },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvDeleteHandler (ctx: *FetchContext) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();
    // create a js string to use
    kv.put("key", .{ .text = "value" }, .{});
    kv.delete("key");
    const text = kv.getText("key", .{}) orelse "deleted";
    defer allocator.free(text);
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.set("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .text = text },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}