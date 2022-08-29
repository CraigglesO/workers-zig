const worker = @import("workers-zig");
const FetchContext = worker.FetchContext;
const Request = worker.Request;
const Response = worker.Response;
const String = worker.String;
const Headers = worker.Headers;
const Cache = worker.Cache;
const Method = worker.Method;

pub fn cacheTextHandler (ctx: *FetchContext) callconv(.Async) void {
  const url = "http://localhost/cacheTest";
    // get the kvinstance from env
    const cache = Cache.new(.{ .none = {} });
    defer cache.free();
    // store the request with cache control headers
    const cacheHeaders = Headers.new();
    defer cacheHeaders.free();
    cacheHeaders.setText("Cache-Control", "max-age=3600");
    cacheHeaders.setText("Content-Type", "text/plain");
    const cacheRes = Response.new(
      .{ .text = "cached response" },
      .{ .status = 200, .statusText = "ok", .headers = &cacheHeaders }
    );
    defer cacheRes.free();
    cache.put(.{ .text = url }, &cacheRes);
    // response
    const res = cache.match(.{ .text = url }, .{}) orelse return ctx.throw(500, "failed to get cache");
    defer res.free();

    ctx.send(&res);
}

pub fn cacheStringHandler (ctx: *FetchContext) callconv(.Async) void {
    const string = String.new("http://localhost/cacheTest");
    defer string.free();
    // get the kvinstance from env
    const cache = Cache.new(.{ .none = {} });
    defer cache.free();
    // store the request with cache control headers
    const cacheHeaders = Headers.new();
    defer cacheHeaders.free();
    cacheHeaders.setText("Cache-Control", "max-age=3600");
    cacheHeaders.setText("Content-Type", "text/plain");
    const cacheRes = Response.new(
      .{ .text = "cached response" },
      .{ .status = 200, .statusText = "ok", .headers = &cacheHeaders }
    );
    defer cacheRes.free();
    cache.put(.{ .string = &string }, &cacheRes);
    // response
    const res = cache.match(.{ .string = &string }, .{}) orelse return ctx.throw(500, "failed to get cache");
    defer res.free();

    ctx.send(&res);
}

pub fn cacheUniqueHandler (ctx: *FetchContext) callconv(.Async) void {
  const url = "http://localhost/cacheTest";
    // get the kvinstance from env
    const cache = Cache.new(.{ .text = "newcache" });
    defer cache.free();
    // store the request with cache control headers
    const cacheHeaders = Headers.new();
    defer cacheHeaders.free();
    cacheHeaders.setText("Cache-Control", "max-age=3600");
    cacheHeaders.setText("Content-Type", "text/plain");
    const cacheRes = Response.new(
      .{ .text = "cached response" },
      .{ .status = 200, .statusText = "ok", .headers = &cacheHeaders }
    );
    defer cacheRes.free();
    cache.put(.{ .text = url }, &cacheRes);
    // response
    const res = cache.match(.{ .text = url }, .{}) orelse return ctx.throw(500, "failed to get cache");
    defer res.free();

    ctx.send(&res);
}

pub fn cacheDeleteHandler (ctx: *FetchContext) callconv(.Async) void {
    const url = "http://localhost/cacheTest";
    // get the kvinstance from env
    const cache = Cache.new(.{ .none = {} });
    defer cache.free();
    // store the request with cache control headers
    const cacheHeaders = Headers.new();
    defer cacheHeaders.free();
    cacheHeaders.setText("Cache-Control", "max-age=3600");
    cacheHeaders.setText("Content-Type", "text/plain");
    const cacheRes = Response.new(
      .{ .text = "cached response" },
      .{ .status = 200, .statusText = "ok", .headers = &cacheHeaders }
    );
    defer cacheRes.free();
    cache.put(.{ .text = url }, &cacheRes);
    _ = cache.delete(.{ .text = url }, .{});
    // response
    const res = cache.match(.{ .text = url }, .{}) orelse Response.new(
      .{ .text = "deleted cached response" },
      .{ .status = 200, .statusText = "ok" }
    );
    defer res.free();

    ctx.send(&res);
}

pub fn cacheIgnoreTextHandler (ctx: *FetchContext) callconv(.Async) void {
    const url = "http://localhost/cacheTest";
    // get the kvinstance from env
    const cache = Cache.new(.{ .none = {} });
    defer cache.free();
    // prep request
    const matchReq = Request.new(
      .{ .text = url },
      .{ .requestInit = .{ .method = Method.Put } },
    );
    defer matchReq.free();
    // store the request with cache control headers
    const cacheHeaders = Headers.new();
    defer cacheHeaders.free();
    cacheHeaders.setText("Cache-Control", "max-age=3600");
    cacheHeaders.setText("Content-Type", "text/plain");
    const cacheRes = Response.new(
      .{ .text = "cached response" },
      .{ .status = 200, .statusText = "ok", .headers = &cacheHeaders }
    );
    defer cacheRes.free();
    cache.put(.{ .text = url }, &cacheRes);
    // response
    const res = cache.match(.{ .request = &matchReq }, .{ .ignoreMethod = true }) orelse return ctx.throw(500, "failed to get cache");
    defer res.free();

    ctx.send(&res);
}

pub fn cacheIgnoreDeleteHandler (ctx: *FetchContext) callconv(.Async) void {
    const url = "http://localhost/cacheTest";
    // get the kvinstance from env
    const cache = Cache.new(.{ .none = {} });
    defer cache.free();
    // prep request
    const matchReq = Request.new(
      .{ .text = url },
      .{ .requestInit = .{ .method = Method.Put } },
    );
    defer matchReq.free();
    // store the request with cache control headers
    const cacheHeaders = Headers.new();
    defer cacheHeaders.free();
    cacheHeaders.setText("Cache-Control", "max-age=3600");
    cacheHeaders.setText("Content-Type", "text/plain");
    const cacheRes = Response.new(
      .{ .text = "cached response" },
      .{ .status = 200, .statusText = "ok", .headers = &cacheHeaders }
    );
    defer cacheRes.free();
    cache.put(.{ .text = url }, &cacheRes);
    _ = cache.delete(.{ .request = &matchReq }, .{ .ignoreMethod = true });
    // response
    const res = cache.match(.{ .text = url }, .{}) orelse Response.new(
      .{ .text = "deleted cached response" },
      .{ .status = 200, .statusText = "ok" }
    );
    defer res.free();

    ctx.send(&res);
}
