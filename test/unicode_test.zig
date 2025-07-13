const std = @import("std");
const unicode = @import("../src/unicode.zig");

test "Detect invisible/control/confusable" {
    try std.testing.expect(unicode.isInvisibleOrSuspicious(0x200B)); // ZWSP
    try std.testing.expect(unicode.isInvisibleOrSuspicious(0x03B1)); // Greek alpha
    try std.testing.expect(unicode.isInvisibleOrSuspicious(0x00));   // NULL
    try std.testing.expect(!unicode.isInvisibleOrSuspicious('A'));
}
