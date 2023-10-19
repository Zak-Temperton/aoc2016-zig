const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Timer = std.time.Timer;
const print = std.debug.print;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day18.txt")[0..100];
const DataType = @Type(.{ .Int = .{ .bits = data.len, .signedness = .unsigned } });

fn parseData() DataType {
    var result: DataType = 0;
    for (data) |char| {
        result <<= 1;
        if (char == '^') {
            result |= 1;
        }
    }
    return result;
}

fn solve(alloc: Allocator, num_rows: usize) !usize {
    var rows = try List(DataType).initCapacity(alloc, num_rows);
    defer rows.deinit();
    try rows.append(parseData());
    for (0..num_rows - 1) |_| {
        const last = rows.getLast();
        var next: DataType = 0;
        const masks: [4]DataType = .{ 0b001, 0b100, 0b011, 0b110 };
        for (2..data.len + 1) |i| {
            const above = (last >> @truncate(data.len - i)) & 0b111;
            for (masks) |mask| {
                if (mask ^ above == 0) {
                    next |= 1;
                    break;
                }
            }
            next <<= 1;
        }
        const above = (last & 0b011) << 1;
        for (masks) |mask| {
            if (mask ^ above == 0) {
                next |= 1;
                break;
            }
        }
        try rows.append(next);
    }

    var count: usize = 0;
    for (rows.items) |row| {
        count += @popCount(~row);
    }
    return count;
}

pub fn main() !void {
    var timer = try Timer.start();
    const p1 = try solve(gpa, 40);
    const p1_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    timer.reset();
    const p2 = try solve(gpa, 40000);
    const p2_time = timer.read();
    print("{d} {d}ns\n", .{ p2, p2_time });
}

test "solve" {
    _ = try solve(std.testing.allocator, 40);
}
