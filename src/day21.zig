const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = &@embedFile("data/day21.txt");

const CircularBuffer = struct {
    const Self = @This();

    buffer: []u8,
    index: u3,
    allocator: Allocator,

    fn init(allocator: Allocator, input: []const u8) !Self {
        var self = .{
            .buffer = try allocator.alloc(u8, input.len),
            .index = 0,
            .allocator = allocator,
        };
        std.mem.copy(u8, self.buffer, input);
        return self;
    }

    fn deinit(self: *Self) void {
        self.allocator.free(self.buffer);
    }

    fn len(self: Self) usize {
        return self.buffer.len;
    }

    fn toString(self: Self) ![]u8 {
        var string: []u8 = try self.allocator.alloc(u8, self.len());
        for (self.buffer[self.index..], 0..) |char, i| {
            string[i] = char;
        }
        if (self.index != 0) for (self.buffer[0..self.index], self.len() - @as(u4, self.index)..) |char, i| {
            string[i] = char;
        };
        return string;
    }

    fn rotateRight(self: *Self, count: u3) void {
        self.index -%= count;
    }

    fn rotateLeft(self: *Self, count: u3) void {
        self.index +%= count;
    }

    fn swap(self: *Self, pos1: u3, pos2: u3) void {
        std.mem.swap(u8, &self.buffer[self.index +% pos1], &self.buffer[self.index +% pos2]);
    }

    fn findAndRotate(self: *Self, letter: u8) void {
        for (0..self.len()) |j| {
            const i: u3 = @truncate(j);
            if (self.buffer[self.index +% i] == letter) {
                if (i >= 4) {
                    self.index -%= i +% 2;
                    return;
                } else {
                    self.index -%= i +% 1;
                    return;
                }
            }
        }
    }

    fn findAndSwapLetter(self: *Self, letter1: u8, letter2: u8) void {
        for (self.buffer, 0..) |l1, idx1| {
            if (l1 == letter1) {
                for (self.buffer[idx1 + 1 ..], idx1 + 1..) |l2, idx2| {
                    if (l2 == letter2) {
                        std.mem.swap(u8, &self.buffer[idx1], &self.buffer[idx2]);
                        return;
                    }
                }
            } else if (l1 == letter2) {
                for (self.buffer[idx1 + 1 ..], idx1 + 1..) |l2, idx2| {
                    if (l2 == letter1) {
                        std.mem.swap(u8, &self.buffer[idx1], &self.buffer[idx2]);
                        return;
                    }
                }
            }
        }
    }

    fn reverse(self: *Self, pos1: u3, pos2: u3) void {
        const diff = pos2 - pos1;
        if (diff == 1) {
            std.mem.swap(u8, &self.buffer[self.index +% pos1], &self.buffer[self.index +% pos2]);
            return;
        }
        const half: u3 = diff / 2;
        for (0..half + 1) |j| {
            const i: u3 = @truncate(j);
            std.mem.swap(u8, &self.buffer[self.index +% pos1 +% i], &self.buffer[self.index +% pos2 -% i]);
        }
    }

    fn move(self: *Self, pos1: u3, pos2: u3) void {
        if (pos1 < pos2) {
            const tmp = self.buffer[pos1 +% self.index];
            for (pos1..pos2) |j| {
                const i: u3 = @truncate(j);
                self.buffer[self.index +% i] = self.buffer[self.index +% i +% 1];
            }
            self.buffer[self.index +% pos2] = tmp;
        } else {
            const tmp = self.buffer[pos1 +% self.index];
            for (0..pos1 - pos2) |j| {
                const i: u3 = pos1 - @as(u3, @truncate(j));
                self.buffer[self.index +% i] = self.buffer[self.index +% i -% 1];
            }
            self.buffer[self.index +% pos2] = tmp;
        }
    }
};

const Instructions = enum {
    rotate,
    reverse,
    move,
    swap,
};

const words = std.ComptimeStringMap(Instructions, .{
    .{ "rotate", .rotate },
    .{ "reverse", .reverse },
    .{ "move", .move },
    .{ "swap", .swap },
});

fn part1(alloc: Allocator, input: []const u8) ![]u8 {
    var password = try CircularBuffer.init(alloc, input);
    defer password.deinit();
    var lines = std.mem.tokenizeAny(u8, data.*, "\r\n");
    while (lines.next()) |line| {
        var tokens = std.mem.tokenizeAny(u8, line, " ");
        switch (words.get(tokens.next().?).?) {
            .move => {
                _ = tokens.next();
                const a = tokens.next().?[0] - '0';
                _ = tokens.next();
                _ = tokens.next();
                const b = tokens.next().?[0] - '0';
                password.move(@truncate(a), @truncate(b));
            },
            .rotate => {
                const a = tokens.next().?[0];
                switch (a) {
                    'b' => {
                        _ = tokens.next();
                        _ = tokens.next();
                        _ = tokens.next();
                        _ = tokens.next();
                        var b = tokens.next().?[0];
                        password.findAndRotate(@truncate(b));
                    },
                    'r' => {
                        var b = tokens.next().?[0] - '0';
                        password.rotateRight(@truncate(b));
                    },
                    'l' => {
                        var b = tokens.next().?[0] - '0';
                        password.rotateLeft(@truncate(b));
                    },
                    else => unreachable,
                }
            },
            .reverse => {
                _ = tokens.next();
                const a = tokens.next().?[0] - 0;
                _ = tokens.next();
                const b = tokens.next().?[0] - 0;
                password.reverse(@truncate(a), @truncate(b));
            },
            .swap => {
                if (std.mem.eql(u8, tokens.next().?, "position")) {
                    const a = tokens.next().?[0];
                    _ = tokens.next();
                    _ = tokens.next();
                    const b = tokens.next().?[0];
                    password.swap(@truncate(a), @truncate(b));
                } else {
                    const a = tokens.next().?[0];
                    _ = tokens.next();
                    _ = tokens.next();
                    const b = tokens.next().?[0];
                    password.findAndSwapLetter(a, b);
                }
            },
        }
    }
    return try password.toString();
}

fn nextPermutation(nums: []u8) void {
    var i = nums.len - 2;
    while (i > 0 and nums[i + 1] <= nums[i]) {
        i -= 1;
    }
    if (nums[i + 1] > nums[i]) {
        var j = nums.len - 1;
        while (nums[j] <= nums[i]) {
            j -= 1;
        }
        std.mem.swap(u8, &nums[i], &nums[j]);
    } else {
        i -= 1;
    }
    std.mem.reverse(u8, nums[i + 1 ..]);
}

fn part2(alloc: Allocator, input: []const u8) ![]u8 {
    var perm = try alloc.dupe(u8, input);
    while (true) : (nextPermutation(perm)) {
        var res = try part1(alloc, perm);
        defer alloc.free(res);
        if (std.mem.eql(u8, res, "fbgdceah")) {
            return perm;
        }
    }
}

pub fn main() !void {
    const input = "abcdefgh";
    var timer = try std.time.Timer.start();
    const p1 = try part1(gpa, input);
    defer gpa.free(p1);
    const p1_time = timer.read();
    const p2 = try part2(gpa, input);
    defer gpa.free(p2);
    const p2_time = timer.read();
    print("{s} {d}ns\n", .{ p1, p1_time });
    print("{s} {d}ns\n", .{ p2, p2_time });
}

test "part1" {
    const input = "abcdefgh";
    const alloc = std.testing.allocator;
    const p1 = try part1(alloc, input);
    defer alloc.free(p1);
}

test "part2" {
    const input = "abcdefgh";
    const alloc = std.testing.allocator;
    const p2 = try part2(alloc, input);
    defer alloc.free(p2);
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
