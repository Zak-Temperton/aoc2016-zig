const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

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
fn solve(num_rows: usize) !usize {
    var rows = try List(DataType).initCapacity(gpa, num_rows);
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
    var timer = try std.time.Timer.start();
    const p1 = try solve(40);
    const p1_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    timer.reset();
    const p2 = try solve(40000);
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

const min3 = std.math.min3;
const max3 = std.math.max3;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
