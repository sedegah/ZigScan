const std = @import("std");
const unicode = @import("unicode.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: zigscan <file>\n", .{});
        return;
    }

    const path = args[1];
    const file = std.fs.cwd().openFile(path, .{ .read = true }) catch |err| {
        std.debug.print("Error opening file '{}': {}\n", .{ path, err });
        return;
    };
    defer file.close();

    const reader = file.reader();
    var buf: [4096]u8 = undefined;

    var line_no: usize = 1;
    while (reader.readUntilDelimiterOrEof(&buf, '\n') catch |err| {
        std.debug.print("Read error: {}\n", .{err});
        return;
    }) |line| {
        // Process the line with proper UTF-8 decoding
        var decoder = std.unicode.Utf8Decoder.init(line);
        var col_no: usize = 1;
        
        while (decoder.next()) |cp| {
            if (unicode.isZeroWidthCharacter(cp)) {
                std.debug.print(
                    "⚠️  Zero-width char at line {} col {}: U+{x:04X} ({s})\n",
                    .{ line_no, col_no, cp, unicode.getZeroWidthCharName(cp) },
                );
            }
            col_no += 1;
        }
        
        if (decoder.errors != 0) {
            std.debug.print("  Warning: UTF-8 errors in line {}\n", .{line_no});
        }
        
        line_no += 1;
    }
}