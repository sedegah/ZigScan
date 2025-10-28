const std = @import("std");

pub fn isZeroWidthCharacter(cp: u21) bool {
    return switch (cp) {
        // Zero-width space
        0x200B => true,
        
        // Zero-width non-joiner
        0x200C => true,
        
        // Zero-width joiner  
        0x200D => true,
        
        // Zero-width no-break space (BOM)
        0xFEFF => true,
        
        // Word joiner (zero-width)
        0x2060 => true,
        
        // Zero-width function application
        0x2061 => true,
        
        // Zero-width invisible times
        0x2062 => true,
        
        // Zero-width invisible separator
        0x2063 => true,
        
        // Zero-width invisible plus
        0x2064 => true,
        
        else => false,
    };
}

pub fn scanForZeroWidth(text: []const u8) !void {
    var line_no: usize = 1;
    var col_no: usize = 1;
    var decoder = std.unicode.Utf8Decoder.init(text);
    var found_count: usize = 0;

    while (decoder.next()) |cp| {
        if (cp == '\n') {
            line_no += 1;
            col_no = 1;
            continue;
        }

        if (isZeroWidthCharacter(cp)) {
            std.debug.print(
                "Zero-width char at line {d} col {d}: U+{x:04X} ({s})\n",
                .{ line_no, col_no, cp, getZeroWidthCharName(cp) },
            );
            found_count += 1;
        }

        col_no += 1;
    }

    if (decoder.errors != 0) {
        std.debug.print("Warning: {d} UTF-8 decoding errors\n", .{decoder.errors});
    }
    
    if (found_count > 0) {
        std.debug.print("Found {d} zero-width characters\n", .{found_count});
    } else {
        std.debug.print("No zero-width characters found\n", .{});
    }
}

fn getZeroWidthCharName(cp: u21) []const u8 {
    return switch (cp) {
        0x200B => "ZERO WIDTH SPACE",
        0x200C => "ZERO WIDTH NON-JOINER", 
        0x200D => "ZERO WIDTH JOINER",
        0xFEFF => "ZERO WIDTH NO-BREAK SPACE (BOM)",
        0x2060 => "WORD JOINER",
        0x2061 => "FUNCTION APPLICATION",
        0x2062 => "INVISIBLE TIMES",
        0x2063 => "INVISIBLE SEPARATOR", 
        0x2064 => "INVISIBLE PLUS",
        else => "UNKNOWN ZERO-WIDTH",
    };
}

// Utility to remove zero-width characters
pub fn removeZeroWidthCharacters(allocator: std.mem.Allocator, text: []const u8) ![]const u8 {
    var result = std.ArrayList(u8).init(allocator);
    defer result.deinit();
    
    var decoder = std.unicode.Utf8Decoder.init(text);
    
    while (decoder.next()) |cp| {
        if (!isZeroWidthCharacter(cp)) {
            try result.writer().writeAll(std.unicode.utf8Encode(cp) catch continue);
        }
    }
    
    return result.toOwnedSlice();
}