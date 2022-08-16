const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    b.is_release = true;
    const mode = b.standardReleaseOptions();
    b.cache_root = "cache";
    b.global_cache_root = "cache";

    const wasm_build = b.addSharedLibrary("zig", "lib/main.zig", .unversioned);
    wasm_build.setOutputDir("dist");
    wasm_build.setTarget(std.zig.CrossTarget {
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });
    wasm_build.build_mode = std.builtin.Mode.ReleaseSmall;
    wasm_build.strip = true;
    wasm_build.linkage = std.build.LibExeObjStep.Linkage.dynamic;
    // wasm_build.verbose_link = true;
    wasm_build.install();

    const exe_tests = b.addTest("lib/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
