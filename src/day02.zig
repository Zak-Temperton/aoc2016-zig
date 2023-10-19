const std = @import("std");
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const List = std.ArrayList;
const print = std.debug.print;
const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

fn part1() u32 {
    var x: u32 = 1;
    var y: u32 = 1;
    var res: u32 = 0;

    for (data) |c| {
        switch (c) {
            'R' => x = @min(x + 1, 2),
            'D' => y = @min(y + 1, 2),
            'L' => x -|= 1,
            'U' => y -|= 1,
            '\n' => {
                res *= 10;
                res += 1 + x + y * 3;
            },
            else => {},
        }
    }
    return res;
}

fn part2(alloc: Allocator) !List(u8) {
    var x: u32 = 1;
    var y: u32 = 1;
    var res = List(u8).init(alloc);
    const keypad = [5][5]u8{
        [_]u8{ '0', '0', '1', '0', '0' },
        [_]u8{ '0', '2', '3', '4', '0' },
        [_]u8{ '5', '6', '7', '8', '9' },
        [_]u8{ '0', 'A', 'B', 'C', '0' },
        [_]u8{ '0', '0', 'D', '0', '0' },
    };

    for (data) |c| {
        switch (c) {
            'R' => {
                var xx = @min(x + 1, 4);
                if (keypad[y][xx] != '0') {
                    x = xx;
                }
            },
            'D' => {
                var yy = @min(y + 1, 4);
                if (keypad[yy][x] != '0') {
                    y = yy;
                }
            },
            'L' => {
                var xx = x -| 1;
                if (keypad[y][xx] != '0') {
                    x = xx;
                }
            },
            'U' => {
                var yy = y -| 1;
                if (keypad[yy][x] != '0') {
                    y = yy;
                }
            },
            '\n' => {
                try res.append(keypad[y][x]);
            },
            else => {},
        }
    }
    return res;
}

pub fn main() !void {
    var timer = try Timer.start();
    const p1 = part1();
    const p1_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    timer.reset();
    const p2 = try part2(gpa);
    defer p2.deinit();
    const p2_time = timer.read();
    print("{s} {d}ns\n", .{ p2.items, p2_time });
}

test "part2" {
    const p2 = try part2(std.testing.allocator);
    defer p2.deinit();
}
