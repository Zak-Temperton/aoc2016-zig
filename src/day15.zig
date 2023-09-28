const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day15.txt");

const Disk = struct {
    const Self = @This();
    size: u8,
    start_pos: u8,
    fn init(size: u8, start_pos: u8) Self {
        return .{
            .size = size,
            .start_pos = start_pos,
        };
    }

    fn getRotation(self: Self, time: u32) u32 {
        var rotation: u5 = @truncate((time + self.start_pos) % (self.size));
        return @as(u32, 1) << rotation;
    }
};

fn solve(disks: []const Disk) u32 {
    var i: u32 = 0;
    while (true) : (i += 1) {
        var x: u32 = 1;
        var j: u32 = 1;
        for (disks) |disk| {
            x |= disk.getRotation(i + j);
            j += 1;
        }
        if (@popCount(x) == 1) {
            return i;
        }
    }
}

pub fn main() !void {
    const disks = [_]Disk{
        Disk.init(13, 11),
        Disk.init(5, 0),
        Disk.init(17, 11),
        Disk.init(3, 0),
        Disk.init(7, 2),
        Disk.init(19, 17),
    };
    const disks2 = disks ++ [_]Disk{Disk.init(11, 0)};
    var timer = try std.time.Timer.start();
    const p1 = solve(&disks);
    const p1_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    timer.reset();
    const p2 = solve(&disks2);
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
