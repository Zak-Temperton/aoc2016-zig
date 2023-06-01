const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day09.txt");

fn nomInt(input: []const u8, i: *usize) usize {
    var int: usize = 0;
    while (input[i.*] >= '0' and input[i.*] <= '9') : (i.* += 1) {
        int = int * 10 + @as(usize, input[i.*] - '0');
    }
    return int;
}

fn readMarker(input: []const u8, i: *usize) ?struct { size: usize, repeats: usize } {
    if (i.* >= input.len - 2) return null;
    i.* += 1;
    const size = nomInt(input, i);
    i.* += 1;
    const repeats = nomInt(input, i);
    i.* += 1;
    return .{ .size = size, .repeats = repeats };
}

fn part1() usize {
    var len: usize = 0;
    var i: usize = 0;
    while (readMarker(data, &i)) |marker| {
        i += marker.size;
        len += marker.size * marker.repeats;
    }
    return len;
}

fn decompress(input: []const u8) usize {
    if (input[0] != '(') return input.len;
    var i: usize = 0;
    var len: usize = 0;
    while (readMarker(input, &i)) |marker| {
        len += decompress(input[i .. i + marker.size]) * marker.repeats;
        i += marker.size;
    }
    return len;
}

fn part2() usize {
    return decompress(data);
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const p1 = part1();
    const p1_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    timer.reset();
    const p2 = part2();
    const p2_time = timer.read();
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

const min = std.math.min;
const min3 = std.math.min3;
const max = std.math.max;
const max3 = std.math.max3;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
