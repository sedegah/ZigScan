const std = @import("std");

pub fn isInvisibleOrSuspicious(c: u21) bool {
    return isInvisible(c) or isControl(c) or isConfusable(c);
}

fn isControl(c: u21) bool {
    return c < 0x20 or (c >= 0x7f and c <= 0x9f);
}

fn isInvisible(c: u21) bool {
    return switch (c) {
        0x200B, 0x200C, 0x200D, 0x2060, 0xFEFF => true,
        else => false,
    };
}

fn isConfusable(c: u21) bool {
    return switch (c) {
        0x03B1, 0x0430, 0xFF41 => true,
        else => false,
    };
}
