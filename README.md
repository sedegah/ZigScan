# ZigScan

ZigScan is a fast CLI tool written in [Zig](https://ziglang.org/) for detecting invisible, control, or suspicious Unicode characters in a file.

## Features

- Detects invisible characters like Zero-width space (ZWSP), BOM, etc.
- Flags control characters (e.g., NULL, DEL, etc.)
- Flags confusables (characters that look like Latin but aren't)

## Build

```bash
zig build
