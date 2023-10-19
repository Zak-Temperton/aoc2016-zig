const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day05.txt");

fn first5Zero(input: [Md5.digest_length]u8) bool {
    return input[0] == 0 and input[1] == 0 and input[2] >> 4 == 0;
}

fn part1(alloc: Allocator) !u64 {
    var out: [Md5.digest_length]u8 = std.mem.zeroes([Md5.digest_length]u8);
    var i: usize = 0;
    var string = List(u8).init(alloc);
    defer string.deinit();
    try string.appendSlice(data[0..8]);

    var num = List(u8).init(alloc);
    defer num.deinit();
    var num_writer = num.writer();
    try formatInt(i, 10, Case.lower, .{}, num_writer);
    try string.appendSlice(num.items);
    Md5.hash(string.items, &out, .{});

    var password: u64 = 0;
    for (0..8) |_| {
        while (!first5Zero(out)) : (i += 1) {
            Md5.hash(string.items, &out, .{});

            num.clearRetainingCapacity();
            string.shrinkRetainingCapacity(8);
            try formatInt(i, 10, Case.lower, .{}, num_writer);
            try string.appendSlice(num.items);
        }
        password = (password << 4) | out[2];
        i += 1;
        Md5.hash(string.items, &out, .{});

        num.clearRetainingCapacity();
        string.shrinkRetainingCapacity(8);
        try formatInt(i, 10, Case.lower, .{}, num_writer);
        try string.appendSlice(num.items);
    }
    return password;
}

fn part2(alloc: Allocator) !u64 {
    var out: [Md5.digest_length]u8 = std.mem.zeroes([Md5.digest_length]u8);
    var i: usize = 0;
    var string = List(u8).init(alloc);
    defer string.deinit();
    try string.appendSlice(data[0..8]);

    var num = List(u8).init(alloc);
    var num_writer = num.writer();
    defer num.deinit();
    try formatInt(i, 10, Case.lower, .{}, num_writer);
    try string.appendSlice(num.items);
    Md5.hash(string.items, &out, .{});

    var password: u64 = 0;
    var check: u8 = 0;
    while (check != 0b11111111) {
        while (!first5Zero(out)) : (i += 1) {
            Md5.hash(string.items, &out, .{});

            num.clearRetainingCapacity();
            string.shrinkRetainingCapacity(8);
            try formatInt(i, 10, Case.lower, .{}, num_writer);
            try string.appendSlice(num.items);
        }
        if (out[2] < 8) {
            const one: u8 = 1;
            if (one << @truncate(out[2]) & check == 0) {
                check |= one << @truncate(out[2]);
                const n = @as(u64, out[3] >> 4);
                password |= n << (@truncate(7 - out[2] << 2));
            }
        }
        i += 1;
        Md5.hash(string.items, &out, .{});

        num.clearRetainingCapacity();
        string.shrinkRetainingCapacity(8);
        try formatInt(i, 10, Case.lower, .{}, num_writer);
        try string.appendSlice(num.items);
    }
    return password;
}

pub fn main() !void {
    var timer = try Timer.start();
    const p1 = try part1(gpa);
    const p1_time = timer.read();
    print("{x} {d}ns\n", .{ p1, p1_time });
    timer.reset();
    const p2 = try part2(gpa);
    const p2_time = timer.read();
    print("{x} {d}ns\n", .{ p2, p2_time });
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

const min = std.math.min;
const min3 = std.math.min3;
const max = std.math.max;
const max3 = std.math.max3;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;

const Md5 = std.crypto.hash.Md5;
const formatInt = std.fmt.formatInt;
const Case = std.fmt.Case;
const FormatOptions = std.fmt.FormatOptions;
const Timer = std.time.Timer;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
