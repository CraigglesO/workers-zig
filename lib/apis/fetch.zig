const common = @import("../bindings/common.zig");
const jsFree = common.jsFree;
const Request = @import("../bindings/request.zig").Request;
const RequestInfo = @import("../bindings/request.zig").RequestInfo;
const RequestOptions = @import("../bindings/request.zig").RequestOptions;
const Response = @import("../bindings/response.zig").Response;
const Array = @import("../bindings/array.zig").Array;

pub extern fn jsFetch (frame: *anyopaque, urlPtr: u32, initPtr: u32, resPtr: *u32) void;
pub fn fetchResp(urlPtr: u32, initPtr: u32) u32 {
  var res: u32 = 0;
  suspend {
    jsFetch(@frame(), urlPtr, initPtr, &res);      
  }
  return res;
}

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1972
pub fn fetch (request: RequestInfo, requestInit: ?RequestOptions) callconv(.Async) Response {
  // url
  const urlID = request.toID();
  defer request.free(urlID);
  // req init
  const reqInit = requestInit orelse RequestOptions{ .none = {} };
  const reqInitID = reqInit.toID();
  defer reqInit.free(reqInitID);
  // fetch
  return Response.init(await async fetchResp(urlID, reqInitID));
}
