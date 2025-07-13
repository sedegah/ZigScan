const std = @import("std");

pub fn build(b: *std.Build) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable(.{
        .name = "zigscan",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = b.standardTargetOptions(.{}),
        .optimize = mode,
    });

    b.installArtifact(exe);

    const test_step = b.addTest(.{ .root_source_file = .{ .path = "test/unicode_test.zig" } });
    const run_tests = b.step("test", "Run tests");
    run_tests.dependOn(&test_step.step);
}
