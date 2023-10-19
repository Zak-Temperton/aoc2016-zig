const std = @import("std");
const Allocator = std.mem.Allocator;
const Map = std.AutoHashMap;
const Timer = std.time.Timer;
const util = @import("util.zig");
const gpa = util.gpa;
const split = std.mem.split;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;
const absInt = std.math.absInt;

const data = @embedFile("data/day01.txt");

fn part1() !i32 {
    var split_iter = split(u8, data, ", ");
    var x: i32 = 0;
    var y: i32 = 0;
    var dir: i32 = 0;
    while (split_iter.next()) |instr| {
        const turn = instr[0];
        const dist = try parseInt(i32, instr[1..], 10);
        switch (turn) {
            'L' => if (dir == 0) {
                dir = 3;
            } else {
                dir -= 1;
            },
            'R' => if (dir == 3) {
                dir = 0;
            } else {
                dir += 1;
            },
            else => unreachable,
        }
        switch (dir) {
            0 => x += dist,
            1 => y -= dist,
            2 => x -= dist,
            3 => y += dist,
            else => unreachable,
        }
    }
    return try absInt(x) + try absInt(y);
}

fn part2(alloc: Allocator) !i32 {
    var x: i32 = 0;
    var y: i32 = 0;
    var dir: i32 = 0;
    var my_hash_map = Map(struct { i32, i32 }, void).init(alloc);
    defer my_hash_map.deinit();

    try my_hash_map.put(.{ x, y }, {});
    var split_iter = split(u8, data, ", ");
    while (split_iter.next()) |instr| {
        const turn = instr[0];
        const dist = try parseInt(i32, instr[1..], 10);

        switch (turn) {
            'L' => if (dir == 0) {
                dir = 3;
            } else {
                dir -= 1;
            },
            'R' => if (dir == 3) {
                dir = 0;
            } else {
                dir += 1;
            },
            else => unreachable,
        }
        var i: u32 = 0;
        while (i < dist) : (i += 1) {
            switch (dir) {
                0 => y += 1,
                1 => x += 1,
                2 => y -= 1,
                3 => x -= 1,
                else => unreachable,
            }
            var v = try my_hash_map.getOrPut(.{ x, y });
            if (v.found_existing) {
                return try absInt(x) + try absInt(y);
            }
        }
    }
    unreachable;
}

pub fn main() !void {
    var timer = try Timer.start();
    const p1 = try part1();
    const p1_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    timer.reset();
    const p2 = try part2(gpa);
    const p2_time = timer.read();
    print("{d} {d}ns\n", .{ p2, p2_time });
}

test "part2" {
    _ = try part2(std.testing.allocator);
}
