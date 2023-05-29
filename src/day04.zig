const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data: []const u8 = @embedFile("data/day04.txt");

fn find(arr: [5]u8, input: u8) ?usize {
    for (arr, 0..) |n, i| {
        if (n == input) {
            return i;
        }
    }
    return null;
}

fn updateMostCommon(most_common: *[5]u8, chars: [26]u32, c: u8, count: u32) void {
    const last_count = if (most_common[4] == 0) 0 else chars[most_common[4] - 'a'];
    if (most_common[4] == 0 or last_count < count or (last_count == count and most_common[4] >= c)) {
        var j: usize = if (find(most_common.*, c)) |n| 5 - n else 1;
        most_common[5 - j] = c;

        while (j < 5) : (j += 1) {
            const other = most_common[4 - j];
            const other_count = if (other == 0) 0 else chars[other - 'a'];
            if (other_count < count or (other_count == count and other >= c)) {
                std.mem.swap(u8, &most_common[4 - j], &most_common[5 - j]);
            }
        }
    }
}

fn parseLine(input: []const u8) !?struct { a: []const u8, b: ?u32, c: ?[]const u8 } {
    if (input.len <= 2) return null;

    var i: u32 = 0;
    var chars = std.mem.zeroes([26]u32);
    var most_common = [_]u8{ 0, 0, 0, 0, 0 };
    while (input[i] >= 'a' and input[i] <= 'z' or input[i] == '-') : (i += 1) {
        if (input[i] != '-') {
            const char = &chars[input[i] - 'a'];
            char.* += 1;
            updateMostCommon(&most_common, chars, input[i], char.*);
        }
    }

    const n = i - 1;
    var val: u32 = 0;
    while (input[i] != '[') : (i += 1) {
        val = (val * 10) + input[i] - '0';
    }

    i += 1;
    for (input[i .. i + 5], most_common) |l, r| {
        if (l != r) {
            while (input[i] != '\n') : (i += 1) {}
            return .{ .a = input[i + 1 ..], .b = null, .c = null };
        }
    }

    while (input[i] != '\n') : (i += 1) {}
    return .{ .a = input[i + 1 ..], .b = val, .c = input[0..n] };
}

fn part1() !u32 {
    var input = data;
    var count: u32 = 0;

    while (try parseLine(input)) |res| {
        input = res.a;
        if (res.b) |val| {
            count += val;
        }
    }
    return count;
}

fn equal(left: []const u8, right: []const u8) bool {
    if (left.len != right.len) return false;
    for (left, right) |l, r| {
        if (l != r) return false;
    }
    return true;
}

fn part2() !u32 {
    var input = data;
    var message = List(u8).init(gpa);
    defer message.deinit();
    while (try parseLine(input)) |res| {
        input = res.a;
        if (res.b) |val| {
            const add = @intCast(u8, val % 26);
            for (res.c.?) |char| {
                if (char != '-') {
                    var c: u8 = char + add;
                    if (c > 'z') {
                        c -= 26;
                    }
                    try message.append(c);
                } else {
                    try message.append(' ');
                }
            }
            if (equal(message.items, "northpole object storage")) return val;
        }
        message.clearRetainingCapacity();
    }
    unreachable;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const p1 = try part1();
    const p1_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    timer.reset();
    const p2 = try part2();
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
