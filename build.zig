const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zigscan",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // This creates a `zig build install` step
    b.installArtifact(exe);

    // Creates `zig build run` step
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Test step (your existing code - good!)
    const test_step = b.addTest(.{ 
        .root_source_file = .{ .path = "test/unicode_test.zig" },
        .target = target,
        .optimize = optimize,
    });
    const run_tests = b.step("test", "Run tests");
    run_tests.dependOn(&test_step.step);

    // Optional: Add lint step
    const lint_step = b.step("lint", "Run zig fmt");
    const lint_cmd = b.addSystemCommand(&.{ "zig", "fmt", "--check", "src/", "test/", "build.zig" });
    lint_step.dependOn(&lint_cmd.step);
}