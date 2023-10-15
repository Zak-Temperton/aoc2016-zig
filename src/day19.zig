const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const LinkedList = std.TailQueue;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day19.txt");

fn part1(num: u32) u32 {
    var i: u5 = 1;
    const two: u32 = 2;
    while (two << (i + 1) <= num) i += 1;
    return 2 * (num - (two << i)) + 1;
}
fn part2(num: u32) u32 {
    var i: u32 = 1;
    while (i * 3 < num) i *= 3;
    return num - i;
}
pub fn main() !void {
    const num = 3004953;
    var timer = try std.time.Timer.start();
    const p1 = part1(num);
    const p1_time = timer.read();
    const p2 = part2(num);
    const p2_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    print("{d} {d}ns\n", .{ p2, p2_time });
}

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const min3 = std.math.min3;
const max3 = std.math.max3;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
