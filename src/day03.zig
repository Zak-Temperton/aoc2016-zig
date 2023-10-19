const std = @import("std");
const Allocator = std.mem.Allocator;
const Timer = std.time.Timer;
const print = std.debug.print;

const data: []const u8 = @embedFile("data/day03.txt");

fn nomWhitespace(input: []const u8) []const u8 {
    var i: usize = 0;
    while (i < input.len and (input[i] == ' ' or input[i] == '\r' or input[i] == '\n')) : (i += 1) {}
    return input[i..];
}

fn nomInt(input: []const u8) ?struct { a: []const u8, b: u32 } {
    if (input.len == 0) return null;
    var i: usize = 0;
    var num: u32 = 0;
    while (input[i] >= '0' and input[i] <= '9') : (i += 1) {
        num = num * 10 + input[i] - '0';
    }
    return .{ .a = input[i..], .b = num };
}

fn parseLine(input: []const u8) ?struct { a: []const u8, b: [3]u32 } {
    var in = input;
    var res = [_]u32{ 0, 0, 0 };
    for (&res) |*n| {
        const r1 = nomWhitespace(in);
        if (nomInt(r1)) |r2| {
            in = r2.a;
            n.* = r2.b;
        } else {
            return null;
        }
    }

    return .{ .a = in, .b = res };
}

fn part1() u32 {
    var input = data;
    var count: u32 = 0;
    while (parseLine(input)) |res| {
        input = res.a;
        const triangle = res.b;
        if (triangle[0] + triangle[1] > triangle[2] and
            triangle[0] + triangle[2] > triangle[1] and
            triangle[1] + triangle[2] > triangle[0])
        {
            count += 1;
        }
    }
    return count;
}

fn parseVertTriangles(input: []const u8) ?struct { a: []const u8, b: [3][3]u32 } {
    if (parseLine(input)) |line1| {
        if (parseLine(line1.a)) |line2| {
            if (parseLine(line2.a)) |line3| {
                return .{ .a = line3.a, .b = .{ line1.b, line2.b, line3.b } };
            }
        }
    }
    return null;
}

fn part2() u32 {
    var input = data;
    var count: u32 = 0;
    while (parseVertTriangles(input)) |res| {
        input = res.a;
        const triangle = res.b;
        var i: u32 = 0;
        while (i < 3) : (i += 1) {
            if (triangle[0][i] + triangle[1][i] > triangle[2][i] and
                triangle[0][i] + triangle[2][i] > triangle[1][i] and
                triangle[1][i] + triangle[2][i] > triangle[0][i])
            {
                count += 1;
            }
        }
    }
    return count;
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
