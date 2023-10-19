const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day20.txt");

const Range = [2]u64;

fn nomWhitespace(input: []const u8) ?[]const u8 {
    var i: usize = 0;
    while (i < input.len and (input[i] == ' ' or input[i] == '\r' or input[i] == '\n')) : (i += 1) {}
    if (i == 0) return null;
    return input[i..];
}

fn nomInt(input: []const u8) ?struct { a: []const u8, b: u64 } {
    if (input.len == 0) return null;
    var i: usize = 0;
    var num: u64 = 0;
    while (input[i] >= '0' and input[i] <= '9') : (i += 1) {
        num = num * 10 + input[i] - '0';
    }
    if (i == 0) return null;
    return .{ .a = input[i..], .b = num };
}

fn nomLine(input: []const u8) ?struct { a: []const u8, b: Range } {
    var str = input;
    var result: Range = undefined;
    if (nomInt(str)) |res| {
        str = res.a;
        result[0] = res.b;
    } else {
        return null;
    }
    if (nomInt(str[1..])) |res| {
        str = res.a;
        result[1] = res.b;
    } else {
        return null;
    }
    if (nomWhitespace(str)) |res| {
        str = res;
    } else {
        return null;
    }
    return .{ .a = str, .b = result };
}

fn parseData(alloc: Allocator) !List(Range) {
    var result = List(Range).init(alloc);
    var str: []const u8 = data;
    while (nomLine(str)) |res| {
        str = res.a;
        try result.append(res.b);
    }
    return result;
}

fn ord(_: void, lhs: Range, rhs: Range) bool {
    return lhs[0] < rhs[0];
}

fn part1(alloc: Allocator) !u64 {
    var ranges = try parseData(alloc);
    defer ranges.deinit();
    sort(Range, ranges.items, {}, ord);
    if (ranges.items[0][0] != 0) return 0;
    var max: u64 = ranges.items[0][1];
    for (ranges.items[1..]) |range| {
        if (range[0] <= max) {
            if (range[1] > max) max = range[1] + 1;
        } else {
            return max;
        }
    }

    return max;
}

fn part2(alloc: Allocator) !u64 {
    var ranges = try parseData(alloc);
    defer ranges.deinit();
    var count: u64 = 0;
    sort(Range, ranges.items, {}, ord);
    if (ranges.items[0][0] != 0) return 0;
    var max: u64 = ranges.items[0][1];

    for (ranges.items[1..]) |range| {
        if (range[0] <= max) {
            if (range[1] > max) max = range[1] + 1;
        } else {
            count += range[0] - max;
            max = range[1] + 1;
        }
    }
    count += 4294967295 -| max;

    return count;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const p1 = try part1(gpa);
    const p1_time = timer.read();
    const p2 = try part2(gpa);
    const p2_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    print("{d} {d}ns\n", .{ p2, p2_time });
}

test "part1" {
    _ = try part1(std.testing.allocator);
}

test "part2" {
    _ = try part2(std.testing.allocator);
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

const sort = std.sort.heap;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
