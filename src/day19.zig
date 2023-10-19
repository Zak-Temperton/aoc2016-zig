const std = @import("std");
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const print = std.debug.print;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day19.txt");

fn part1(num: u32) u32 {
    var i: u5 = 1;
    const two: u32 = 2;
    while (two << (i + 1) <= num) i += 1;
    return 2 * (num - (two << i)) + 1;
}
fn part2(num: u32) u32 {
    var i: u32 = 1;
    while (i * 3 < num) i *= 3;
    return num - i;
}
pub fn main() !void {
    const num = 3004953;
    var timer = try Timer.start();
    const p1 = part1(num);
    const p1_time = timer.read();
    const p2 = part2(num);
    const p2_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    print("{d} {d}ns\n", .{ p2, p2_time });
}
