const std = @import("std");
const unicode = @import("unicode.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Handle command-line arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: zigscan <file>\n", .{});
        return;
    }

    const file_path = args[1];
    const file = std.fs.cwd().openFile(file_path, .{ .read = true }) catch |err| {
        std.debug.print("Error opening file '{}': {}\n", .{ file_path, err });
        return;
    };
    defer file.close();

    // Buffered reading for efficiency
    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var line_number: usize = 0;

    while (try reader.readUntilDelimiterOrEofAlloc(allocator, '\n')) |line| {
        defer allocator.free(line);
        line_number += 1;

        // Decode UTF-8 safely
        var decoder = std.unicode.Utf8View.init(line);
        var iterator = decoder.iterator();

        var byte_index: usize = 0;
        while (iterator.nextCodepoint()) |cp| {
            const cp_len = std.unicode.utf8CodepointLength(cp) catch 1;

            if (unicode.isInvisibleOrSuspicious(cp)) {
                std.debug.print(
                    "⚠️ Suspicious char at line {d}, byte {d}: U+{x:04X}\n",
                    .{ line_number, byte_index + 1, cp },
                );
            }

            byte_index += cp_len;
        }

        if (decoder.iterator().invalid != 0) {
            std.debug.print("⚠️ Warning: malformed UTF-8 sequence on line {d}\n", .{ line_number });
        }
    }
}
