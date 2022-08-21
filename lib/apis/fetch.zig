const jsFree = @import("../bindings/common.zig").jsFree;
const Request = @import("../bindings/request.zig").Request;
const RequestInfo = @import("../bindings/request.zig").RequestInfo;
const RequestOptions = @import("../bindings/request.zig").RequestOptions;
const Response = @import("../bindings/response.zig").Response;
const Array = @import("../bindings/array.zig").Array;

pub extern fn jsFetch(frame: *anyopaque, urlPtr: u32, initPtr: u32, resPtr: *u32) void;
pub fn fetchResp(urlPtr: u32, initPtr: u32) u32 {
  var res: u32 = 0;
  suspend {
    jsFetch(@frame(), urlPtr, initPtr, &res);      
  }
  return res;
}

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1972
pub fn fetch (request: RequestInfo, requestInit: RequestOptions) callconv(.Async) Response {
  const urlID = request.getID();
  defer jsFetch(urlID);
  const reqInitID = requestInit.toID();
  defer jsFree(reqInitID);

  // setup arg array
  const args = Array.new();
  defer args.free();
  args.push(urlID);
  args.push(reqInitID);

  return Response{ .id = await async fetchResp(urlID, reqInitID) };
}