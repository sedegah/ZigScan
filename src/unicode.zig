const std = @import("std");

pub fn isInvisibleOrSuspicious(cp: u21) bool {
    return switch (cp) {
        0...31, 127 => true,
        0x200B,
        0x200C,
        0x200D,
        0xFEFF,
        0x2060,
        0x2061,
        0x2062,
        0x2063,
        0x2064,
        0x00A0,
        0x1680,
        0x2028,
        0x2029,
        0x202F,
        0x205F,
        0x3000 => true,
        else => false,
    };
}

pub fn isPrintable(cp: u21) bool {
    return !isInvisibleOrSuspicious(cp);
}

pub fn scanText(text: []const u8) !void {
    var line_no: usize = 1;
    var col_no: usize = 1;
    var decoder = std.unicode.Utf8Decoder.init(text);

    while (decoder.next()) |cp| {
        if (cp == '\n') {
            line_no += 1;
            col_no = 1;
            continue;
        }

        if (isInvisibleOrSuspicious(cp)) {
            std.debug.print(
                "⚠️  Suspicious char at line {d} col {d}: U+{x:04X}\n",
                .{ line_no, col_no, cp },
            );
        }

        col_no += 1;
    }

    if (decoder.errors != 0) {
        std.debug.print("❌ UTF-8 decoding errors encountered: {d}\n", .{decoder.errors});
    }
}
