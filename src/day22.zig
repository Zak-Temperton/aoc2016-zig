const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Timer = std.time.Timer;
const tokenize = std.mem.tokenizeAny;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;
const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day22.txt");

pub fn main() !void {
    var timer = try Timer.start();
    const p1 = try part1(gpa);
    const p1_time = timer.read();
    const p2 = try part2(gpa);
    const p2_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    print("{d} {d}ns\n", .{ p2, p2_time });
}

fn part1(alloc: Allocator) !usize {
    var nodes = List([2]u16).init(alloc);
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

fn part2(alloc: Allocator) !usize {
    var lines = tokenize(u8, data, "\r\n");
    var map = List(bool).init(alloc);
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
    return part2b(alloc, zero, map.items);
}

fn part2b(alloc: Allocator, zero: usize, map: []bool) !usize {
    var count: usize = 0;
    var next = List(usize).init(alloc);
    defer next.deinit();
    try next.append(zero);
    map[zero] = false;
    blk: while (true) : (count += 1) {
        var next_next = List(usize).init(alloc);
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

test "part1" {
    _ = try part1(std.testing.allocator);
}

test "part2" {
    _ = try part2(std.testing.allocator);
}
