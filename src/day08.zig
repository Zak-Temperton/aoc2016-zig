const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day08.txt");

const Screen = struct {
    pixels: [6]u50,

    const Self = @This();

    fn new() Self {
        return .{ .pixels = std.mem.zeroes([6]u50) };
    }

    fn rect(self: *Self, w: u6, h: u6) void {
        for (0..min(h, 6)) |y| {
            self.pixels[y] |= (@as(u50, 1) << min(w, 50)) - 1;
        }
    }

    fn rotateRow(self: *Self, row: u6, rot: u6) void {
        var new_row = self.pixels[row] << rot;
        new_row |= self.pixels[row] >> (50 - rot);
        self.pixels[row] = new_row;
    }

    fn rotateCol(self: *Self, col: u6, rot: u6) void {
        if (rot == 6) return;
        const one: u50 = 1;
        const mask: u50 = one << col;
        var tmp: [6]u50 = undefined;
        @memcpy(&tmp, &self.pixels);
        for (0..6) |i| {
            const j = (i + rot) % 6;
            self.pixels[j] &= ~mask;
            self.pixels[j] |= tmp[i] & mask;
        }
    }

    fn pixelOnCount(self: Self) usize {
        var count: usize = 0;
        for (self.pixels) |row| count += @popCount(row);
        return count;
    }

    fn print(self: Self) [306]u8 {
        var i: usize = 0;
        var out: [306]u8 = undefined;
        for (self.pixels) |pixel_row| {
            for (0..50) |j| {
                if (pixel_row >> @truncate(u6, j) & 1 == 1) {
                    out[i] = '#';
                } else {
                    out[i] = ' ';
                }
                i += 1;
            }
            out[i] = '\n';
            i += 1;
        }
        return out;
    }
};

fn nomInt(i: *usize) u6 {
    var num: u6 = @truncate(u6, data[i.*] - '0');
    if (data[i.* + 1] >= '0' and data[i.* + 1] <= '9') {
        num = (num * 10) + @truncate(u6, data[i.* + 1] - '0');
        i.* += 2;
        return num;
    } else {
        i.* += 1;
        return num;
    }
}

fn runInstructions() Screen {
    var i: usize = 0;
    var screen = Screen.new();
    while (i < data.len - 2) {
        if (data[i + 1] == 'e') {
            i += 5;
            const x = nomInt(&i);
            i += 1;
            const y = nomInt(&i);
            screen.rect(x, y);
        } else if (data[i + 7] == 'r') {
            i += 13;
            const row = nomInt(&i);
            i += 4;
            const rot = nomInt(&i);
            screen.rotateRow(row, rot);
        } else {
            i += 16;
            const col = nomInt(&i);
            i += 4;
            const rot = nomInt(&i);
            screen.rotateCol(col, rot);
        }
        i += 2;
    }
    return screen;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const screen = runInstructions();
    const shared_time = timer.lap();
    const p1 = screen.pixelOnCount();
    const p1_time = timer.read() + shared_time;
    print("{d} {d}ns\n", .{ p1, p1_time });
    timer.reset();
    const p2 = screen.print();
    const p2_time = timer.read() + shared_time;
    print("{s}{d}ns\n", .{ p2, p2_time });
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
