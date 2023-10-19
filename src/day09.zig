const std = @import("std");
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const print = std.debug.print;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day09.txt");

fn nomInt(input: []const u8, i: *usize) usize {
    var int: usize = 0;
    while (input[i.*] >= '0' and input[i.*] <= '9') : (i.* += 1) {
        int = int * 10 + @as(usize, input[i.*] - '0');
    }
    return int;
}

fn readMarker(input: []const u8, i: *usize) ?struct { size: usize, repeats: usize } {
    if (i.* >= input.len - 2) return null;
    i.* += 1;
    const size = nomInt(input, i);
    i.* += 1;
    const repeats = nomInt(input, i);
    i.* += 1;
    return .{ .size = size, .repeats = repeats };
}

fn part1() usize {
    var len: usize = 0;
    var i: usize = 0;
    while (readMarker(data, &i)) |marker| {
        i += marker.size;
        len += marker.size * marker.repeats;
    }
    return len;
}

fn decompress(input: []const u8) usize {
    if (input[0] != '(') return input.len;
    var i: usize = 0;
    var len: usize = 0;
    while (readMarker(input, &i)) |marker| {
        len += decompress(input[i .. i + marker.size]) * marker.repeats;
        i += marker.size;
    }
    return len;
}

fn part2() usize {
    return decompress(data);
}

pub fn main() !void {
    var timer = try Timer.start();
    const p1 = part1();
    const p1_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    timer.reset();
    const p2 = part2();
    const p2_time = timer.read();
    print("{d} {d}ns\n", .{ p2, p2_time });
}
