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

pub fn r2StreamHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the r2Bucket from env
    const r2 = ctx.env.r2("TEST_BUCKET") orelse {
      ctx.throw(500, "Could not find \"TEST_BUCKET\"");
      return;
    };
    defer r2.free();
    // put
    const putRes = r2.put("key", .{ .text = "value" }, .{});
    defer putRes.free();
    // get
    const getRes = r2.get("key", .{});
    defer getRes.free();
    const stream = switch (getRes) {
      .r2objectBody => |bod| bod.body(),
      else => {
        ctx.throw(500, "Could not get body");
        return {};
      }
    };
    defer stream.free();
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .stream = &stream },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn r2TextHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the r2Bucket from env
    const r2 = ctx.env.r2("TEST_BUCKET") orelse {
      ctx.throw(500, "Could not find \"TEST_BUCKET\"");
      return;
    };
    defer r2.free();
    // put
    const putRes = r2.put("key", .{ .text = "value" }, .{});
    defer putRes.free();
    // get
    const getRes = r2.get("key", .{});
    defer getRes.free();
    const text = switch (getRes) {
      .r2objectBody => |bod| bod.text(),
      else => {
        ctx.throw(500, "Could not get body");
        return {};
      },
    };
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

pub fn r2StringHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the r2Bucket from env
    const r2 = ctx.env.r2("TEST_BUCKET") orelse {
      ctx.throw(500, "Could not find \"TEST_BUCKET\"");
      return;
    };
    defer r2.free();
    // put
    const inStr = String.new("value");
    defer inStr.free();
    const putRes = r2.put("key", .{ .string = &inStr }, .{});
    defer putRes.free();
    // get
    const getRes = r2.get("key", .{});
    defer getRes.free();
    const string = switch (getRes) {
      .r2objectBody => |bod| bod.string(),
      else => {
        ctx.throw(500, "Could not get body");
        return {};
      },
    };
    defer string.free();
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .string = &string },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn r2ArrayBufferHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the r2Bucket from env
    const r2 = ctx.env.r2("TEST_BUCKET") orelse {
      ctx.throw(500, "Could not find \"TEST_BUCKET\"");
      return;
    };
    defer r2.free();
    // put
    const bytes = [_]u8{ 0, 1, 2, 3};
    const ab = ArrayBuffer.new(bytes[0..]);
    defer ab.free();
    const putRes = r2.put("key", .{ .arrayBuffer = &ab }, .{});
    defer putRes.free();
    // get
    const getRes = r2.get("key", .{});
    defer getRes.free();
    const resAB = switch (getRes) {
      .r2objectBody => |bod| bod.arrayBuffer(),
      else => {
        ctx.throw(500, "Could not get body");
        return {};
      },
    };
    defer resAB.free();
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .arrayBuffer = &resAB },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn r2BytesHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the r2Bucket from env
    const r2 = ctx.env.r2("TEST_BUCKET") orelse {
      ctx.throw(500, "Could not find \"TEST_BUCKET\"");
      return;
    };
    defer r2.free();
    // put
    const bytes = [_]u8{ 0, 1, 2, 3};
    const putRes = r2.put("key", .{ .bytes = bytes[0..] }, .{});
    defer putRes.free();
    // get
    const getRes = r2.get("key", .{});
    defer getRes.free();
    const resBytes = switch (getRes) {
      .r2objectBody => |bod| bod.bytes(),
      else => {
        ctx.throw(500, "Could not get body");
        return {};
      },
    };
    defer allocator.free(resBytes);
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .bytes = resBytes },
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

pub fn r2ObjectHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the r2Bucket from env
    const r2 = ctx.env.r2("TEST_BUCKET") orelse {
      ctx.throw(500, "Could not find \"TEST_BUCKET\"");
      return;
    };
    defer r2.free();
    // put
    const obj = TestObj{ .a = 1, .b = "test" };
    const jsObj = obj.toObject();
    defer jsObj.free();
    const putRes = r2.put("key", .{ .object = &jsObj }, .{});
    defer putRes.free();
    // get
    const getRes = r2.get("key", .{});
    defer getRes.free();
    const resObject = switch (getRes) {
      .r2objectBody => |bod| bod.object(),
      else => {
        ctx.throw(500, "Could not get body");
        return {};
      },
    };
    defer resObject.free();
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .object = &resObject },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn r2JSONHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the r2Bucket from env
    const r2 = ctx.env.r2("TEST_BUCKET") orelse {
      ctx.throw(500, "Could not find \"TEST_BUCKET\"");
      return;
    };
    defer r2.free();
    // put
    const obj = TestObj{ .a = 1, .b = "test" };
    const jsObj = obj.toObject();
    defer jsObj.free();
    const putRes = r2.put("key", .{ .object = &jsObj }, .{});
    defer putRes.free();
    // get
    const getRes = r2.get("key", .{});
    defer getRes.free();
    const resJSON = switch (getRes) {
      .r2objectBody => |bod| bod.json(TestObj),
      else => {
        ctx.throw(500, "Could not get body");
        return {};
      },
    };
    defer std.json.parseFree(TestObj, resJSON.?, .{ .allocator = allocator });
    const resObject = resJSON.?.toObject();
    defer resObject.free();
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .object = &resObject },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn r2HeadHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the r2Bucket from env
    const r2 = ctx.env.r2("TEST_BUCKET") orelse {
      ctx.throw(500, "Could not find \"TEST_BUCKET\"");
      return;
    };
    defer r2.free();
    // put
    const obj = TestObj{ .a = 1, .b = "test" };
    const jsObj = obj.toObject();
    defer jsObj.free();
    const putRes = r2.put("key", .{ .object = &jsObj }, .{});
    defer putRes.free();
    // head
    const headRes = r2.head("key") orelse return ctx.throw(500, "Could not find \"key\"");
    defer headRes.free();
    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    // response
    const res = Response.new(
        .{ .objectID = headRes.id },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn r2DeleteHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the r2Bucket from env
    const r2 = ctx.env.r2("TEST_BUCKET") orelse {
      ctx.throw(500, "Could not find \"TEST_BUCKET\"");
      return;
    };
    defer r2.free();
    // put
    const putRes = r2.put("key", .{ .text = "value" }, .{});
    defer putRes.free();
    // delete
    r2.delete("key");
    // get
    const getRes = r2.get("key", .{});
    defer getRes.free();
    const text = switch (getRes) {
      .r2objectBody => |bod| bod.text(),
      else => "value deleted",
    };
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

pub fn r2ListHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the r2Bucket from env
    const r2 = ctx.env.r2("TEST_BUCKET") orelse {
      ctx.throw(500, "Could not find \"TEST_BUCKET\"");
      return;
    };
    defer r2.free();
    // put
    const putRes = r2.put("key0", .{ .text = "value0" }, .{});
    defer putRes.free();
    const putRes1 = r2.put("key1", .{ .text = "value1" }, .{});
    defer putRes1.free();
    const putRes2 = r2.put("key2", .{ .text = "value2" }, .{});
    defer putRes2.free();
    const putRes3 = r2.put("key3", .{ .text = "value3" }, .{});
    defer putRes3.free();
    const putRes4 = r2.put("key4", .{ .text = "value4" }, .{});
    defer putRes4.free();

    // list
    const r2objects = r2.list(.{});
    defer r2objects.free();
    // build an object to return
    const obj = Object.new();
    defer obj.free();
    // truncated
    obj.setID("truncated", (if (r2objects.truncated()) True else False));
    // cursor
    const cursor = r2objects.cursor();
    defer allocator.free(cursor);
    obj.setText("cursor", cursor);
    // delimitedPrefixes
    var delimitedPrefixes = r2objects.delimitedPrefixes();
    defer delimitedPrefixes.free();
    const prefixes = Array.new();
    defer prefixes.free();
    while (delimitedPrefixes.next()) |delimitedPrefix| {
      defer delimitedPrefix.free();
      prefixes.push(delimitedPrefix);
    }
    obj.set("delimitedPrefixes", prefixes);
    // objects
    var objects = r2objects.objects();
    defer objects.free();
    const objRes = Array.new();
    defer objRes.free();
    while (objects.next()) |object| {
      defer object.free();
      objRes.push(object);
    }
    obj.set("objects", objRes);

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

pub fn r2R2ObjectHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the r2Bucket from env
    const r2 = ctx.env.r2("TEST_BUCKET") orelse {
      ctx.throw(500, "Could not find \"TEST_BUCKET\"");
      return;
    };
    defer r2.free();
    // put
    const putRes = r2.put("key", .{ .text = "value" }, .{});
    defer putRes.free();
    // get
    const r2object = r2.head("key") orelse return ctx.throw(500, "Could not find \"key\"");
    defer r2object.free();
    // build object
    const obj = Object.new();
    defer obj.free();
    // key
    const key = r2object.key();
    defer allocator.free(key);
    obj.setText("key", key);
    // version
    const version = r2object.version();
    defer allocator.free(version);
    obj.setText("version", version);
    // size
    const size = r2object.size();
    obj.setNum("size", u64, size);
    // etag
    const etag = r2object.etag();
    defer allocator.free(etag);
    obj.setText("etag", etag);
    // httpEtag
    const httpEtag = r2object.httpEtag();
    defer allocator.free(httpEtag);
    obj.setText("httpEtag", httpEtag);
    // uploaded
    const uploaded = r2object.uploaded();
    defer uploaded.free();
    obj.set("uploaded", uploaded);
    // httpMetadata
    const httpMetadata = r2object.httpMetadata();
    const httpMetadataObj = httpMetadata.toObject();
    defer httpMetadataObj.free();
    obj.set("httpMetadata", httpMetadataObj);
    // customMetadata
    const customMetadata = r2object.customMetadata();
    defer customMetadata.free();
    obj.set("customMetadata", customMetadata);
    // range
    const range = r2object.range();
    if (range) |r| {
      const rangeObj = r.toObject();
      defer rangeObj.free();
      obj.set("range", rangeObj);
    }

    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    r2object.writeHttpMetadata(headers);
    // response
    const res = Response.new(
        .{ .object = &obj },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn r2R2ObjectBodyHandler (ctx: *FetchContext) callconv(.Async) void {
    // get the r2Bucket from env
    const r2 = ctx.env.r2("TEST_BUCKET") orelse {
      ctx.throw(500, "Could not find \"TEST_BUCKET\"");
      return;
    };
    defer r2.free();
    // put
    const putRes = r2.put("key", .{ .text = "value" }, .{});
    defer putRes.free();
    // get
    const getRes = r2.get("key", .{ .range = .{ .offset = 2 } });
    defer getRes.free();
    const r2ObjectBody = switch (getRes) {
      .r2objectBody => |bod| bod,
      else => {
        ctx.throw(500, "Could not get body");
        return {};
      },
    };
    // build object
    const obj = Object.new();
    defer obj.free();
    // key
    const key = r2ObjectBody.key();
    defer allocator.free(key);
    obj.setText("key", key);
    // version
    const version = r2ObjectBody.version();
    defer allocator.free(version);
    obj.setText("version", version);
    // size
    const size = r2ObjectBody.size();
    obj.setNum("size", u64, size);
    // etag
    const etag = r2ObjectBody.etag();
    defer allocator.free(etag);
    obj.setText("etag", etag);
    // httpEtag
    const httpEtag = r2ObjectBody.httpEtag();
    defer allocator.free(httpEtag);
    obj.setText("httpEtag", httpEtag);
    // uploaded
    const uploaded = r2ObjectBody.uploaded();
    defer uploaded.free();
    obj.set("uploaded", uploaded);
    // httpMetadata
    const httpMetadata = r2ObjectBody.httpMetadata();
    const httpMetadataObj = httpMetadata.toObject();
    defer httpMetadataObj.free();
    obj.set("httpMetadata", httpMetadataObj);
    // customMetadata
    const customMetadata = r2ObjectBody.customMetadata();
    defer customMetadata.free();
    obj.set("customMetadata", customMetadata);
    // range
    const range = r2ObjectBody.range();
    if (range) |r| {
      const rangeObj = r.toObject();
      defer rangeObj.free();
      obj.set("range", rangeObj);
    }

    // headers
    const headers = Headers.new();
    defer headers.free();
    headers.setText("Content-Type", "text/plain");
    r2ObjectBody.writeHttpMetadata(headers);
    // response
    const res = Response.new(
        .{ .object = &obj },
        .{ .status = 200, .statusText = "ok", .headers = &headers }
    );
    defer res.free();

    ctx.send(&res);
}
