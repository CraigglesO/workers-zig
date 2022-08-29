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

const MetaTest = struct {
    name: []const u8 = "",
    input: u32 = 0,
};

pub fn kvStringHandler (ctx: *FetchContext) callconv(.Async) void {
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
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .string = &text },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvStringWithMetadataHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();
    // create a js string to use
    const jsStr = String.new("value");
    defer jsStr.free();
    // prep meta
    const metaObj = MetaTest{ .name = "string", .input = 1 };
    // store
    kv.putMetadata("key", .{ .string = &jsStr }, MetaTest, metaObj, .{});
    // get
    const stringMeta = kv.getStringWithMetadata("key", .{}) orelse {
        ctx.throw(500, "Could not find KV key's value");
        return;
    };
    defer stringMeta.free();
    // prep obj
    const obj = Object.new();
    defer obj.free();
    obj.set("value", &stringMeta.value);
    obj.set("meta", &stringMeta.metadata.?);
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "application/json");
    // response
    const res = Response.new(
        .{ .object = &obj },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvTextHandler (ctx: *FetchContext) callconv(.Async) void {
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
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .text = text },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvTextWithMetadataHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();
    // prep meta
    const metaObj = MetaTest{ .name = "text2", .input = 2 };
    // store
    kv.putMetadata("key", .{ .text = "value2" }, MetaTest, metaObj, .{});
    // get
    const textMeta = kv.getTextWithMetadata("key", .{}) orelse {
        ctx.throw(500, "Could not find KV key's value");
        return;
    };
    defer textMeta.free();
    // prep obj
    const obj = Object.new();
    defer obj.free();
    obj.setText("value", textMeta.value);
    obj.set("meta", &textMeta.metadata.?);
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "application/json");
    // response
    const res = Response.new(
        .{ .object = &obj },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvTextWithExpireTtlHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();
    kv.put("expire", .{ .text = "expiringText" }, .{ .expirationTtl = 100 });
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .none = {} },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub const DateObj = struct {
    date: u32,
};

pub fn kvTextWithExpireHandler (ctx: *FetchContext) callconv(.Async) void {
    const dateObj = ctx.req.json(DateObj) orelse return ctx.throw(500, "Failed to get body.");
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();
    kv.put("expire", .{ .text = "expiringText" }, .{ .expiration = dateObj.date });
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .none = {} },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvTextCacheTtlHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();
    kv.put("key", .{ .text = "value" }, .{});
    const text = kv.getText("key", .{ .cacheTtl = 3_600 }) orelse {
        ctx.throw(500, "Could not find KV key's value");
        return;
    };
    defer allocator.free(text);
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
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
        obj.setNum("a", u32, self.a);
        obj.setText("b", self.b);

        return obj;
    }
};

pub fn kvObjectHandler (ctx: *FetchContext) callconv(.Async) void {
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
    headers.setText("Content-Type", "application/json");
    // response
    const res = Response.new(
        .{ .string = &body },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvObjectWithMetadataHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();
    // build the object
    const inObj = TestObj{ .a = 1, .b = "test" };
    const jsObj = inObj.toObject();
    defer jsObj.free();
    // prep meta
    const metaObj = MetaTest{ .name = "text3", .input = 3 };
    // store
    kv.putMetadata("key", .{ .object = &jsObj }, MetaTest, metaObj, .{});
    // get
    const objMeta = kv.getObjectWithMetadata("key", .{}) orelse {
        ctx.throw(500, "Could not find KV key's value");
        return;
    };
    defer objMeta.free();
    // prep obj
    const obj = Object.new();
    defer obj.free();
    obj.set("value", &objMeta.value);
    obj.set("meta", &objMeta.metadata.?);
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "application/json");
    // response
    const res = Response.new(
        .{ .object = &obj },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvJSONHandler (ctx: *FetchContext) callconv(.Async) void {
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
    defer std.json.parseFree(TestObj, getObj, .{ .allocator = allocator });
    const getObjJS = getObj.toObject();
    defer getObjJS.free();
    // get obj as string
    const body = getObjJS.stringify();
    defer body.free();
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "application/json");
    // response
    const res = Response.new(
        .{ .string = &body },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvArraybufferHandler (ctx: *FetchContext) callconv(.Async) void {
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
    headers.setText("Content-Type", "application/json");
    // response
    const res = Response.new(
        .{ .arrayBuffer = &getAB },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvArrayBufferWithMetadataHandler (ctx: *FetchContext) callconv(.Async) void {
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
    // prep meta
    const metaObj = MetaTest{ .name = "text4", .input = 4 };
    // store
    kv.putMetadata("ab", .{ .arrayBuffer = &ab }, MetaTest, metaObj, .{});
    // get
    const abMeta = kv.getArrayBufferWithMetadata("ab", .{}) orelse {
        ctx.throw(500, "Could not find KV key's value");
        return;
    };
    defer abMeta.free();
    // prep obj
    const obj = Object.new();
    defer obj.free();
    // convert ab to uint8array
    const uint8 = abMeta.value.uint8Array();
    defer uint8.free();
    obj.set("value", &uint8);
    obj.set("meta", &abMeta.metadata.?);
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "application/json");
    // response
    const res = Response.new(
        .{ .object = &obj },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvStreamHandler (ctx: *FetchContext) callconv(.Async) void {
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
    headers.setText("Content-Type", "application/json");
    // response
    const res = Response.new(
        .{ .stream = &getStream },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

// TODO: Ensure metadata works...
pub fn kvStreamWithMetadataHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();
    // build the object
    const bytes = [_]u8{ 0, 1, 2, 3};
    // prep meta
    const metaObj = MetaTest{ .name = "text6", .input = 6 };
    // store
    kv.putMetadata("bytes", .{ .bytes = bytes[0..] }, MetaTest, metaObj, .{});
    // get
    const bytesMeta = kv.getStreamWithMetadata("bytes", .{}) orelse {
        ctx.throw(500, "Could not find KV key's value");
        return;
    };
    defer bytesMeta.free();
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "application/json");
    // response
    const res = Response.new(
        .{ .stream = &bytesMeta.value },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvBytesHandler (ctx: *FetchContext) callconv(.Async) void {
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
    headers.setText("Content-Type", "application/json");
    // response
    const res = Response.new(
        .{ .bytes = getBytes },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvBytesWithMetadataHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();
    // build the object
    const bytes = [_]u8{ 0, 1, 2, 3};
    // prep meta
    const metaObj = MetaTest{ .name = "text5", .input = 5 };
    // store
    kv.putMetadata("bytes", .{ .bytes = bytes[0..] }, MetaTest, metaObj, .{});
    // get
    const bytesMeta = kv.getBytesWithMetadata("bytes", .{}) orelse {
        ctx.throw(500, "Could not find KV key's value");
        return;
    };
    defer bytesMeta.free();
    // prep obj
    const obj = Object.new();
    defer obj.free();
    // convert bytes->ab->uint8array
    const ab = ArrayBuffer.new(bytesMeta.value);
    defer ab.free();
    const uint8 = ab.uint8Array();
    defer uint8.free();
    obj.set("value", &uint8);
    obj.set("meta", &bytesMeta.metadata.?);
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "application/json");
    // response
    const res = Response.new(
        .{ .object = &obj },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvDeleteHandler (ctx: *FetchContext) callconv(.Async) void {
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
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .text = text },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn kvListHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the kvinstance from env
    const kv = ctx.env.kv("TEST_NAMESPACE") orelse {
      ctx.throw(500, "Could not find \"TEST_NAMESPACE\"");
      return;
    };
    defer kv.free();

    // store a bunch of values
    kv.put("list1", .{ .text = "value1" }, .{});
    kv.put("list2", .{ .text = "value2" }, .{});
    kv.put("list3", .{ .text = "value3" }, .{});
    kv.put("list4", .{ .text = "value4" }, .{});
    const metaObj = MetaTest{ .name = "test", .input = 5 };
    kv.putMetadata("list5", .{ .text = "value5" }, MetaTest, metaObj, .{});

    // list kv
    const listResult = kv.list(.{});
    defer listResult.free();
    const listComplete = listResult.listComplete();
    const cursor = listResult.cursor();
    defer allocator.free(cursor);
    var keys = listResult.keys();
    defer keys.free();

    // build an object explaining what we see
    const obj = Object.new();
    defer obj.free();
    if (listComplete) obj.setID("listComplete", True)
    else obj.setID("listComplete", False);
    obj.setText("cursor", cursor);
    const arr = Array.new();
    defer arr.free();
    while (keys.next()) |*key| {
        defer key.free();
        // name
        const name = key.name();
        defer allocator.free(name);
        // meta
        const metadata = key.metaObject();
        defer metadata.?.free();
        // prep obj
        const keyObj = Object.new();
        defer keyObj.free();
        // set values
        keyObj.setText("name", name);
        keyObj.setID("metadata", (if (metadata) |*m| m.id else Undefined));
        // store
        arr.push(&keyObj);
    }
    obj.set("keys", &arr);
    
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .object = &obj },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}
