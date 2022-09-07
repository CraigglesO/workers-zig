const std = @import("std");
const argon2 = std.crypto.pwhash.argon2;
const strHash = argon2.strHash;
const strVerify = argon2.strVerify;
const allocator = std.heap.page_allocator;

const salt: [:0]const u8 = "randomsalt";

pub fn argonHashHandler (args: [][:0]const u8) []const u8 {
    var password = args[0];
    // hash the password
    var buf: [128]u8 = undefined;
    const passSalt = std.mem.concat(allocator, u8, &.{ password, salt }) catch "";
    const hash = strHash(
        passSalt,
        .{
            .allocator = allocator,
            .params = .{ .t = 100, .m = 64, .p = 1 },
            .mode = argon2.Mode.argon2i,
        },
        &buf,
    ) catch "";

    // strip the first 29 description bytes ('$argon2i$v=19$m=64,t=100,p=1$')
    const slice = hash[29..];

    return slice;
}

pub fn argonVerifyHandler (args: [][:0]const u8) []const u8 {
    var password = args[0];
    var hash = args[1];
    // build password
    var passSalt = std.mem.concat(allocator, u8, &.{ password, salt }) catch "";
    // build hash
    var front = "$argon2i$v=19$m=64,t=100,p=1$";
    var frontHash = std.mem.concat(allocator, u8, &.{ front, hash }) catch "";
    // verify
    strVerify(frontHash, passSalt, .{ .allocator = allocator }) catch return "fail";
    return "pass";
}
