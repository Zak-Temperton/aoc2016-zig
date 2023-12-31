const std = @import("std");
const Builder = std.build.Builder;
const LazyPath = std.build.LazyPath;
const LibExeObjStep = std.build.LibExeObjStep;

const required_zig_version = std.SemanticVersion.parse("0.11.0") catch unreachable;

pub fn build(b: *Builder) void {
    if (comptime @import("builtin").zig_version.order(required_zig_version) == .lt) {
        std.debug.print(
            \\Error: Your version of Zig is missing features that are needed for this template.
            \\You will need to download a newer build.
            \\
            \\    https://ziglang.org/download/
            \\
            \\
        , .{});
        std.os.exit(1);
    }

    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardOptimizeOption(.{});

    const install_all = b.step("install_all", "Install all days");
    const install_all_tests = b.step("install_tests_all", "Install tests for all days");
    const run_all = b.step("run_all", "Run all days");

    const generate = b.step("generate", "Generate stub files from template/template.zig");
    const build_generate = b.addExecutable(.{
        .name = "generate",
        .root_source_file = .{ .path = "template/generate.zig" },
        .target = target,
        .optimize = mode,
    });
    const run_generate = b.addRunArtifact(build_generate);
    run_generate.cwd = std.fs.path.dirname(@src().file).?;
    generate.dependOn(&run_generate.step);

    // Set up an exe for each day
    var day: u32 = 1;
    while (day <= 25) : (day += 1) {
        const dayString = b.fmt("day{:0>2}", .{day});
        const zigFile = b.fmt("src/{s}.zig", .{dayString});

        const exe = b.addExecutable(.{
            .name = dayString,
            .root_source_file = LazyPath.relative(zigFile),
            .target = target,
            .optimize = mode,
        });

        b.installArtifact(exe);

        const install_cmd = b.addInstallArtifact(exe, .{});

        const run_test = b.addTest(.{
            .name = b.fmt("test_{s}", .{dayString}),
            .root_source_file = .{ .path = zigFile },
        });

        const build_test = b.addExecutable(.{
            .name = b.fmt("test_{s}", .{dayString}),
            .root_source_file = .{ .path = zigFile },
        });

        const install_test = b.addInstallArtifact(build_test, .{});

        {
            const step_key = b.fmt("install_{s}", .{dayString});
            const step_desc = b.fmt("Install {s}.exe", .{dayString});
            const install_step = b.step(step_key, step_desc);
            install_step.dependOn(&install_cmd.step);
            install_all.dependOn(&install_cmd.step);
        }

        {
            const step_key = b.fmt("test_{s}", .{dayString});
            const step_desc = b.fmt("Run tests in {s}", .{zigFile});
            const step = b.step(step_key, step_desc);
            step.dependOn(&run_test.step);
        }

        {
            const step_key = b.fmt("install_tests_{s}", .{dayString});
            const step_desc = b.fmt("Install test_{s}.exe", .{dayString});
            const step = b.step(step_key, step_desc);
            step.dependOn(&install_test.step);
            install_all_tests.dependOn(&install_test.step);
        }

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(&install_cmd.step);
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_desc = b.fmt("Run {s}", .{dayString});
        const run_step = b.step(dayString, run_desc);
        run_step.dependOn(&run_cmd.step);
        run_all.dependOn(&run_cmd.step);
    }

    // Set up tests for util.zig
    {
        const test_util = b.step("test_util", "Run tests in util.zig");
        const test_cmd = b.addTest(.{
            .root_source_file = .{ .path = "src/util.zig" },
        });
        const run_unit_tests = b.addRunArtifact(test_cmd);
        test_util.dependOn(&run_unit_tests.step);
    }

    // Set up test executable for util.zig
    {
        const test_util = b.step("install_tests_util", "Run tests in util.zig");
        const test_exe = b.addTest(.{
            .root_source_file = .{ .path = "src/util.zig" },
        });

        const install = b.addInstallArtifact(test_exe, .{});
        test_util.dependOn(&install.step);
    }

    // Set up a step to run all tests
    {
        const test_step = b.step("test", "Run all tests");
        const test_cmd = b.addTest(.{
            .root_source_file = .{ .path = "src/test_all.zig" },
            .target = target,
            .optimize = mode,
        });
        const run_unit_tests = b.addRunArtifact(test_cmd);
        test_step.dependOn(&run_unit_tests.step);
    }

    // Set up a step to build tests (but not run them)
    {
        const test_build = b.step("install_tests", "Install test_all.exe");
        const test_exe = b.addTest(.{
            .root_source_file = .{ .path = "src/test_all.zig" },
            .target = target,
            .optimize = mode,
        });

        const test_exe_install = b.addInstallArtifact(test_exe, .{});
        test_build.dependOn(&test_exe_install.step);
    }
}
