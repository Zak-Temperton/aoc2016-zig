const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day22.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const p1 = try part1();
    const p1_time = timer.read();
    const p2 = try part2();
    const p2_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    print("{d} {d}ns\n", .{ p2, p2_time });
}

fn part1() !usize {
    var nodes = List([2]u16).init(gpa);
    var lines = tokenize(u8, data, "\r\n");
    defer nodes.deinit();
    _ = lines.next();
    _ = lines.next();
    var count: usize = 0;
    while (lines.next()) |line| {
        var words = tokenize(u8, line, " T");
        _ = words.next();
        _ = words.next();
        const used = try parseInt(u16, words.next().?, 10);
        const avail = try parseInt(u16, words.next().?, 10);
        for (nodes.items) |node| {
            if (node[0] < avail and node[1] > used) {
                count += 1;
            }
        }
        try nodes.append(.{ used, avail });
    }
    return count;
}

fn part2() !usize {
    var lines = tokenize(u8, data, "\r\n");
    var map = List(bool).init(gpa);
    defer map.deinit();
    _ = lines.next();
    _ = lines.next();
    var zero: usize = 0;
    var z: usize = 0;
    while (lines.next()) |line| {
        var words = tokenize(u8, line, " T");
        _ = words.next();
        _ = words.next();
        const used = try parseInt(u16, words.next().?, 10);
        if (used == zero) zero = z;
        try map.append(used <= 95);
        z += 1;
    }
    return part2b(zero, map.items);
}

fn part2b(zero: usize, map: []bool) !usize {
    var count: usize = 0;
    var next = List(usize).init(gpa);
    defer next.deinit();
    try next.append(zero);
    map[zero] = false;
    blk: while (true) : (count += 1) {
        var next_next = List(usize).init(gpa);
        for (next.items) |item| {
            if (item == 37 * 26) break :blk;
            const x = item / 26;
            const y = item % 26;
            if (x != 0 and map[item - 26]) {
                map[item - 26] = false;
                try next_next.append(item - 26);
            }
            if (x != 37 and map[item + 26]) {
                map[item + 26] = false;
                try next_next.append(item + 26);
            }
            if (y != 0 and map[item - 1]) {
                map[item - 1] = false;
                try next_next.append(item - 1);
            }
            if (y != 25 and map[item + 1]) {
                map[item + 1] = false;
                try next_next.append(item + 1);
            }
        }
        next.deinit();
        next = next_next;
    }
    return count + 36 * 5;
}

// Useful stdlib functions
const tokenize = std.mem.tokenizeAny;
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
