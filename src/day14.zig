const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Timer = std.time.Timer;
const print = std.debug.print;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day14.txt");

const Md5 = std.crypto.hash.Md5;
const bytesToHex = std.fmt.bytesToHex;

fn hasChain(buf: [Md5.digest_length]u8, chain_len: u3) ?u4 {
    var count: u4 = 1;
    const b1: u4 = @truncate(buf[0] >> 4);
    const b2: u4 = @truncate(buf[0]);
    if (b1 == b2) count = 2;
    var last = b2;
    for (buf[1..]) |byte| {
        const c1: u4 = @truncate(byte >> 4);
        if (last == c1) {
            if (count == chain_len - 1) {
                return last;
            }
            count += 1;
        } else {
            last = c1;
            count = 1;
        }
        const c2: u4 = @truncate(byte);
        if (last == c2) {
            if (count == chain_len - 1) {
                return last;
            }
            count += 1;
        } else {
            last = c2;
            count = 1;
        }
    }
    return null;
}

fn part1Hash(b: []const u8, out: *[Md5.digest_length]u8) void {
    Md5.hash(b, out, .{});
}

fn part2Hash(b: []const u8, out: *[Md5.digest_length]u8) void {
    Md5.hash(b, out, .{});
    for (0..2016) |_|
        Md5.hash(&bytesToHex(out, .lower), out, .{});
}

fn solve(comptime hash: fn ([]const u8, *[Md5.digest_length]u8) void, alloc: Allocator) !usize {
    const input = "ihaygndm";
    var index: usize = 0;
    var keys = List(usize).init(alloc);
    defer keys.deinit();
    var triples = List(struct { index: usize, char: u4, valid: bool }).init(alloc);
    defer triples.deinit();
    var i: usize = 0;
    var buf: [Md5.digest_length]u8 = undefined;
    while (keys.items.len < 64) : (index += 1) {
        if (index >= 1000) {
            if (triples.items.len > i and triples.items[i].index == index - 1000) {
                if (triples.items[i].valid) try keys.append(index - 1000);
                i += 1;
            }
        }
        const x: []u8 = try std.fmt.allocPrint(alloc, "{s}{d}", .{ input, index });
        defer alloc.free(x);
        hash(x, &buf);
        if (hasChain(buf, 3)) |triple| {
            if (hasChain(buf, 5)) |pentuple| {
                for (triples.items[i..]) |*entry| {
                    if (entry.char == pentuple) entry.valid = true;
                }
            }
            try triples.append(.{ .index = index, .char = triple, .valid = false });
        }
    }
    return keys.getLast();
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const p1 = try solve(part1Hash, gpa);
    const p1_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    timer.reset();
    const p2 = try solve(part2Hash, gpa);
    const p2_time = timer.read();
    print("{d} {d}ns\n", .{ p2, p2_time });
}

test "part1" {
    _ = try solve(part1Hash, std.testing.allocator);
}

test "part2" {
    _ = try solve(part2Hash, std.testing.allocator);
}
