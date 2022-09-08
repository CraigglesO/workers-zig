const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
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
    b.use_stage1 = true;

    // ensure main is building
    const wasm_build = b.addSharedLibrary("zig", "lib/main.zig", .unversioned);
    wasm_build.setTarget(std.zig.CrossTarget {
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });
    wasm_build.linkage = std.build.LibExeObjStep.Linkage.dynamic;
    wasm_build.install();

    // build tests for freestanding wasm
    const tests_build = b.addSharedLibrary("tests", "lib/tests.zig", .unversioned);
    tests_build.setTarget(std.zig.CrossTarget {
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });
    tests_build.build_mode = std.builtin.Mode.ReleaseSmall;
    tests_build.strip = true;
    tests_build.linkage = std.build.LibExeObjStep.Linkage.dynamic;
    tests_build.addPackagePath("workers-zig", "lib/main.zig");
    tests_build.install();

    // build tests for wasi wasm
    const tests_wasi_build = b.addSharedLibrary("tests_wasi", "lib/testsWASI.zig", .unversioned);
    tests_wasi_build.setTarget(std.zig.CrossTarget {
        .cpu_arch = .wasm32,
        .os_tag = .wasi,
    });
    tests_wasi_build.build_mode = std.builtin.Mode.ReleaseSmall;
    tests_wasi_build.strip = true;
    tests_wasi_build.linkage = std.build.LibExeObjStep.Linkage.dynamic;
    tests_wasi_build.addPackagePath("workers-zig", "lib/main.zig");
    tests_wasi_build.install();

    const exe_tests = b.addTest("lib/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
