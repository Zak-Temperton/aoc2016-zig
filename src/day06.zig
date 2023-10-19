const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const Timer = std.time.Timer;
const util = @import("util.zig");
const gpa = util.gpa;
const print = std.debug.print;

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
                char.* = @truncate(k);
            }
        }
    }

    return least_common;
}

pub fn main() !void {
    var timer = try Timer.start();
    const p1 = part1();
    const p1_time = timer.read();
    print("{s} {d}ns\n", .{ p1, p1_time });
    timer.reset();
    const p2 = part2();
    const p2_time = timer.read();
    print("{s} {d}ns\n", .{ p2, p2_time });
}
