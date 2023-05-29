const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day06.txt");

fn parseLine(input: []const u8) ?[8]u8 {
    if (input.len < 8) return null;
    var output: [8]u8 = undefined;
    @memcpy(&output, input[0..8]);
    return output;
}

fn part1() [8]u8 {
    var columns = [8][26]u32{
        std.mem.zeroes([26]u32),
        std.mem.zeroes([26]u32),
        std.mem.zeroes([26]u32),
        std.mem.zeroes([26]u32),
        std.mem.zeroes([26]u32),
        std.mem.zeroes([26]u32),
        std.mem.zeroes([26]u32),
        std.mem.zeroes([26]u32),
    };

    var i: usize = 10;
    var most_common = parseLine(data).?;
    for (most_common, 0..) |char, j| {
        const column = &columns[j];
        column[char - 'a'] += 1;
        if (column[most_common[j] - 'a'] < column[char - 'a']) {
            most_common[j] = char;
        }
    }

    while (parseLine(data[i..])) |line| : (i += 10) {
        for (line, 0..) |char, j| {
            const column = &columns[j];
            column[char - 'a'] += 1;
            if (column[most_common[j] - 'a'] < column[char - 'a']) {
                most_common[j] = char;
            }
        }
    }

    return most_common;
}

fn part2() [8]u8 {
    var columns = [8][26]u32{
        std.mem.zeroes([26]u32),
        std.mem.zeroes([26]u32),
        std.mem.zeroes([26]u32),
        std.mem.zeroes([26]u32),
        std.mem.zeroes([26]u32),
        std.mem.zeroes([26]u32),
        std.mem.zeroes([26]u32),
        std.mem.zeroes([26]u32),
    };

    var i: usize = 0;

    while (parseLine(data[i..])) |line| : (i += 10) {
        for (line, 0..) |char, j| {
            const column = &columns[j];
            column[char - 'a'] += 1;
        }
    }
    var least_common: [8]u8 = undefined;
    @memcpy(&least_common, data[0..8]);

    for (columns, &least_common) |column, *char| {
        for (column, 'a'..) |count, k| {
            if (count < column[char.* - 'a']) {
                char.* = @truncate(u8, k);
            }
        }
    }

    return least_common;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const p1 = part1();
    const p1_time = timer.read();
    print("{s} {d}ns\n", .{ p1, p1_time });
    timer.reset();
    const p2 = part2();
    const p2_time = timer.read();
    print("{s} {d}ns\n", .{ p2, p2_time });
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
