const std = @import("std");
const allocator = std.heap.page_allocator;
const eql = std.mem.eql;
const worker = @import("workers-zig");

const argon = @import("tests/crypto/argon.zig");

export fn _start () void {
  const stdout = std.io.getStdOut().writer();
  const args = std.process.argsAlloc(allocator) catch return;
  defer std.process.argsFree(allocator, args);

  const route = args[0];

  var response: []const u8 = "";
  if (eql(u8, "argonHash", route)) response = argon.argonHashHandler(args[1..]);
  if (eql(u8, "argonVerify", route)) response = argon.argonVerifyHandler(args[1..]);
  stdout.print("{s}", .{response}) catch {};
}
