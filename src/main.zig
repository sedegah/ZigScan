const std = @import("std");
const unicode = @import("unicode.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: zigscan <file>\n", .{});
        return;
    }

    const path = args[1];
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const reader = file.reader();
    var line_num: usize = 0;

    var buffered_reader = std.io.bufferedReader(reader);
    var reader_stream = buffered_reader.reader();

    while (try reader_stream.readUntilDelimiterOrEofAlloc(allocator, '\n')) |line| {
        defer allocator.free(line);
        line_num += 1;

        var col_num: usize = 0;
        var decoder = std.unicode.Utf8Decoder.init(line);

        while (decoder.next()) |cp| {
            if (unicode.isInvisibleOrSuspicious(cp)) {
                std.debug.print("Suspicious char at line {d} col {d}: U+{x:04X}\n", .{ line_num, col_num + 1, cp });
            }
            col_num += std.unicode.utf8CodePointByteCount(cp);
        }

        if (decoder.errors != 0) {
             std.debug.print("Error: Malformed UTF-8 sequence on line {d}\n", .{line_num});
        }
    }
}
