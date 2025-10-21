explain this const std = @import("std");
const unicode = @import("unicode.zig");

pub fn main() void {
    const args = std.process.argsAlloc(std.heap.page_allocator) catch unreachable;
    if (args.len < 2) {
        std.debug.print("Usage: zigscan <file>\n", .{});
        return;
    }

    const path = args[1];
    const file = std.fs.cwd().openFile(path, .{}) catch {
        std.debug.print("Error: could not open file: {}\n", .{path});
        return;
    };
    defer file.close();

    const reader = file.reader();
    var buf: [4096]u8 = undefined;

    var pos: usize = 0;
    while (reader.readUntilDelimiterOrEof(&buf, '\n') catch null) |line| {
        for (line) |b, i| {
            const cp = b;
            if (unicode.isInvisibleOrSuspicious(cp)) {
                std.debug.print("Suspicious char at line {} col {}: U+{x:04X}\n", .{ pos+1, i+1, cp });
            }
        }
        pos += 1;
    }
}
