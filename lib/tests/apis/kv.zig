const std = @import("std");
const allocator = std.heap.page_allocator;

const workersZig = @import("workers-zig");
const FetchContext = workersZig.FetchContext;
const Response = workersZig.Response;
const String = workersZig.String;
const Headers = workersZig.Headers;
const Object = workersZig.Object;
const ArrayBuffer = workersZig.ArrayBuffer;

pub export fn kvString (ctxID: u32) void {
    // build the ctx
    const ctx = FetchContext.init(ctxID) catch {
        const err = String.new("Unable to prepare a FetchContext.");
        defer err.free();
        err.throw();
        return;
    };
    // build / keep a frame alive
    const frame = allocator.create(@Frame(kvStringHandler)) catch {
        ctx.throw(500, "Unable to prepare the kvStringHandler handler.");
        return;
    };
    frame.* = async kvStringHandler(ctx);
    // tell the context about the frame for later destruction
    ctx.frame.* = frame;
}
fn kvStringHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();
    // create a js string to use
    const jsStr = String.new("value");
    defer jsStr.free();
    await async kv.put("key", .{ .string = &jsStr }, .{});
    const text = await async kv.getString("key", .{}) orelse {
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

pub export fn kvText (ctxID: u32) void {
    // build the ctx
    const ctx = FetchContext.init(ctxID) catch {
        const err = String.new("Unable to prepare a FetchContext.");
        defer err.free();
        err.throw();
        return;
    };
    // build / keep a frame alive
    const frame = allocator.create(@Frame(kvTextHandler)) catch {
        ctx.throw(500, "Unable to prepare the kvTextHandler handler.");
        return;
    };
    frame.* = async kvTextHandler(ctx);
    // tell the context about the frame for later destruction
    ctx.frame.* = frame;
}
fn kvTextHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();
    await async kv.put("key2", .{ .text = "value2" }, .{});
    const text = await async kv.getText("key2", .{}) orelse {
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

pub export fn kvObject (ctxID: u32) void {
    // build the ctx
    const ctx = FetchContext.init(ctxID) catch {
        const err = String.new("Unable to prepare a FetchContext.");
        defer err.free();
        err.throw();
        return;
    };
    // build / keep a frame alive
    const frame = allocator.create(@Frame(kvObjectHandler)) catch {
        ctx.throw(500, "Unable to prepare the kvObjectHandler handler.");
        return;
    };
    frame.* = async kvObjectHandler(ctx);
    // tell the context about the frame for later destruction
    ctx.frame.* = frame;
}
fn kvObjectHandler (ctx: *FetchContext) callconv(.Async) void {
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
    await async kv.put("obj", .{ .object = &jsObj }, .{});
    const getObj = await async kv.getObject("obj", .{}) orelse {
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

// pub export fn kvJSON (ctxID: u32) void {
//     // build the ctx
//     const ctx = FetchContext.init(ctxID) catch {
//         const err = String.new("Unable to prepare a FetchContext.");
//         defer err.free();
//         err.throw();
//         return;
//     };
//     // build / keep a frame alive
//     const frame = allocator.create(@Frame(kvJSONHandler)) catch {
//         ctx.throw(500, "Unable to prepare the kvJSONHandler handler.");
//         return;
//     };
//     frame.* = async kvJSONHandler(ctx);
//     // tell the context about the frame for later destruction
//     ctx.frame.* = frame;
// }
// fn kvJSONHandler (ctx: *FetchContext) callconv(.Async) void {
//     // get the kvinstance from env
//     const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
//       ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
//       return;
//     };
//     defer kv.free();

//     // build the object
//     const obj = TestObj{ .a = 1, .b = "test" };
//     const jsObj = obj.toObject();
//     defer jsObj.free();
//     await async kv.put("obj", .{ .jsObject = &jsObj }, .{});
//     // const getObj = await async kv.getJSON(TestObj, "obj", .{}) orelse {
//     //     ctx.throw(500, "Could not find KV key's value");
//     //     return;
//     // };
//     const getObj = await async kv.getJSON(TestObj, "obj", .{}) orelse {
//         ctx.throw(500, "Could not find KV key's value");
//         return;
//     };
//     const getObjJS = getObj.toObject();
//     defer getObjJS.free();
//     // get obj as string
//     const body = getObjJS.stringify();
//     defer body.free();
//     // headers
//     const headers = Headers.new();
//     defer headers.free();
//     headers.set("Content-Type", "application/json");
//     // response
//     const res = Response.new(
//         .{ .string = &body },
//         .{ .status = 200, .statusText = "ok", .headers = &headers }
//     );
//     defer res.free();

//     ctx.send(&res);
// }

pub export fn kvArraybuffer (ctxID: u32) void {
    // build the ctx
    const ctx = FetchContext.init(ctxID) catch {
        const err = String.new("Unable to prepare a FetchContext.");
        defer err.free();
        err.throw();
        return;
    };
    // build / keep a frame alive
    const frame = allocator.create(@Frame(kvArraybufferHandler)) catch {
        ctx.throw(500, "Unable to prepare the kvArraybufferHandler handler.");
        return;
    };
    frame.* = async kvArraybufferHandler(ctx);
    // tell the context about the frame for later destruction
    ctx.frame.* = frame;
}
fn kvArraybufferHandler (ctx: *FetchContext) callconv(.Async) void {
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
    await async kv.put("ab", .{ .arrayBuffer = &ab }, .{});
    const getAB = await async kv.getArrayBuffer("ab", .{}) orelse {
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

pub export fn kvBytes (ctxID: u32) void {
    // build the ctx
    const ctx = FetchContext.init(ctxID) catch {
        const err = String.new("Unable to prepare a FetchContext.");
        defer err.free();
        err.throw();
        return;
    };
    // build / keep a frame alive
    const frame = allocator.create(@Frame(kvBytesHandler)) catch {
        ctx.throw(500, "Unable to prepare the kvBytesHandler handler.");
        return;
    };
    frame.* = async kvBytesHandler(ctx);
    // tell the context about the frame for later destruction
    ctx.frame.* = frame;
}
fn kvBytesHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();

    // build the object
    const arr = [_]u8{ 0, 1, 2, 3};
    await async kv.put("bytes", .{ .bytes = arr[0..] }, .{});
    const getBytes = await async kv.getBytes("bytes", .{}) orelse {
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

pub export fn kvDelete (ctxID: u32) void {
    // build the ctx
    const ctx = FetchContext.init(ctxID) catch {
        const err = String.new("Unable to prepare a FetchContext.");
        defer err.free();
        err.throw();
        return;
    };
    // build / keep a frame alive
    const frame = allocator.create(@Frame(kvDeleteHandler)) catch {
        ctx.throw(500, "Unable to prepare the kvDeleteHandler handler.");
        return;
    };
    frame.* = async kvDeleteHandler(ctx);
    // tell the context about the frame for later destruction
    ctx.frame.* = frame;
}
fn kvDeleteHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();
    // create a js string to use
    await async kv.put("key", .{ .text = "value" }, .{});
    await async kv.delete("key");
    const text = await async kv.getText("key", .{}) orelse "deleted";
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