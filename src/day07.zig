const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day07.txt");

fn containsABBA(input: []const u8) struct { end: usize, abba: bool } {
    var i: usize = if (input[0] == '[' or input[0] == ']') 1 else 0;
    while (input[i + 3] >= 'a' and input[i + 3] <= 'z') : (i += 1) {
        if (input[i] == input[i + 3] and input[i + 1] == input[i + 2] and input[i] != input[i + 1]) {
            while (input[i + 3] >= 'a' and input[i + 3] <= 'z') : (i += 1) {}
            return .{ .end = i + 3, .abba = true };
        }
    }
    return .{ .end = i + 3, .abba = false };
}

fn parseLineABBA(input: []const u8) ?struct { end: usize, valid: bool } {
    if (input.len < 4) return null;
    var i: usize = 0;
    var valid = false;
    var hypernet = false;
    while (input[i] != '\r') {
        var res = containsABBA(input[i..]);
        i += res.end;
        if (res.abba) {
            if (hypernet) {
                while (input[i] != '\r') : (i += 1) {}
                return .{ .end = i + 2, .valid = false };
            } else if (!valid) {
                valid = true;
            }
        }
        hypernet = !hypernet;
    }
    return .{ .end = i + 2, .valid = valid };
}

fn part1() usize {
    var count: usize = 0;
    var i: usize = 0;
    var j: usize = 0;
    while (parseLineABBA(data[i..])) |line| {
        j += 1;
        i += line.end;
        if (line.valid) count += 1;
    }
    return count;
}

const ABA = struct { a: u8, b: u8 };

fn findABAs(input: []const u8, aba: bool) !struct { end: usize, set: Map(ABA, void) } {
    var i: usize = if (input[0] == '[' or input[0] == ']') 1 else 0;
    var list = Map(ABA, void).init(gpa);
    while (input[i + 2] >= 'a' and input[i + 2] <= 'z') : (i += 1) {
        if (input[i] == input[i + 2] and input[i] != input[i + 1]) {
            if (aba) {
                try list.put(.{ .a = input[i], .b = input[i + 1] }, {});
            } else {
                try list.put(.{ .a = input[i + 1], .b = input[i] }, {});
            }
        }
    }
    return .{ .end = i + 2, .set = list };
}

fn parseLineABA(input: []const u8) !?struct { end: usize, valid: bool } {
    if (input.len < 2) return null;
    var aba_set = Map(ABA, void).init(gpa);
    var bab_set = Map(ABA, void).init(gpa);
    defer {
        aba_set.deinit();
        bab_set.deinit();
    }
    var aba = true;
    var i: usize = 0;
    while (input[i] != '\r') {
        var res = try findABAs(input[i..], aba);
        defer res.set.deinit();
        i += res.end;
        var iter = res.set.keyIterator();
        if (aba) {
            while (iter.next()) |item| {
                if (bab_set.contains(item.*)) {
                    while (input[i] != '\r') : (i += 1) {}
                    return .{ .end = i + 2, .valid = true };
                } else {
                    try aba_set.put(item.*, {});
                }
            }
        } else {
            while (iter.next()) |item| {
                if (aba_set.contains(item.*)) {
                    while (input[i] != '\r') : (i += 1) {}
                    return .{ .end = i + 2, .valid = true };
                } else {
                    try bab_set.put(item.*, {});
                }
            }
        }

        aba = !aba;
    }
    return .{ .end = i + 2, .valid = false };
}

fn part2() !usize {
    var count: usize = 0;
    var i: usize = 0;
    while (try parseLineABA(data[i..])) |line| {
        i += line.end;
        if (line.valid) count += 1;
    }
    return count;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const p1 = part1();
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
