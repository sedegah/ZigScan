const std = @import("std");
const unicode = @import("unicode.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len >= 2) {
        try scanFile(allocator, args[1]);
    } else {
        try scanStdin(allocator);
    }
}

fn scanFile(allocator: std.mem.Allocator, path: []const u8) !void {
    const file = std.fs.cwd().openFile(path, .{ .read = true }) catch |err| {
        std.debug.print(" Error opening file '{}': {}\n", .{ path, err });
        return;
    };
    defer file.close();

    std.debug.print(" Scanning file: {}\n", .{path});
    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var line_no: usize = 1;
    var buf: [4096]u8 = undefined;

    while (reader.readUntilDelimiterOrEof(&buf, '\n') catch |err| {
        std.debug.print(" Read error: {}\n", .{err});
        return;
    }) |line| {
        scanLine(line, line_no);
        line_no += 1;
    }

    std.debug.print(" Scan complete.\n", .{});
}

fn scanStdin(allocator: std.mem.Allocator) !void {
    const stdin = std.io.getStdIn();
    var buffered = std.io.bufferedReader(stdin.reader());
    var reader = buffered.reader();

    std.debug.print("  Enter or pipe text to scan (Ctrl+D to end):\n\n", .{});

    var line_no: usize = 1;
    while (try reader.readUntilDelimiterOrEofAlloc(allocator, '\n')) |line| {
        defer allocator.free(line);
        scanLine(line, line_no);
        line_no += 1;
    }

    std.debug.print("\n Scan complete.\n", .{});
}

fn scanLine(line: []const u8, line_no: usize) void {
    var utf8 = std.unicode.Utf8View.init(line);
    var it = utf8.iterator();

    var byte_index: usize = 0;
    while (it.nextCodepoint()) |cp| {
        const cp_len = std.unicode.utf8CodepointLength(cp) catch 1;

        if (unicode.isInvisibleOrSuspicious(cp)) {
            std.debug.print(
                "  Suspicious char at line {} col {}: U+{x:04X}\n",
                .{ line_no, byte_index + 1, cp },
            );
        }

        byte_index += cp_len;
    }

    if (it.invalid != 0) {
        std.debug.print("  Malformed UTF-8 sequence on line {}\n", .{line_no});
    }
}
