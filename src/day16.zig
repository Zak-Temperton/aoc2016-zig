const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

fn U(comptime size: usize) type {
    return @Type(.{ .Int = .{
        .signedness = std.builtin.Signedness.unsigned,
        .bits = size,
    } });
}

fn bitReverse(comptime S: usize, disk: U(S), size: usize) U(S) {
    var result: U(S) = 0;
    const inverse = ~disk;
    for (0..size) |i| {
        result <<= 1;
        result |= ((inverse >> @truncate(i)) & 1);
    }
    return result;
}

fn fillDisk(comptime S: usize, init: U(S), init_size: usize) U(S) {
    var size = init_size;
    var disk = @as(U(2 * S), init);
    while (size < S) {
        const b = bitReverse(2 * S, disk, size);
        disk <<= @truncate(size + 1);
        disk |= b;
        size += size + 1;
    }
    return @truncate(disk >> @truncate(size - S));
}

fn checksum(comptime S: usize, value: U(S)) struct { U(S), usize } {
    const mask: U(S) = 0b11;
    var s: usize = S;
    var result = value;
    {
        var sum: U(S) = 0;
        for (0..(s / 2)) |i| {
            const pair = result & (mask << @truncate(i * 2));
            if (@popCount(pair) == 2 or @popCount(pair) == 0) sum |= @as(U(S), 1) << @truncate(i);
        }
        s /= 2;

        result = sum;
    }
    while (s & 1 == 0) : (s /= 2) {
        var sum: U(S) = 0;
        for (0..(s / 2)) |i| {
            const pair = result & (mask << @truncate(i * 2));
            if (@popCount(pair) == 2 or @popCount(pair) == 0) sum |= @as(U(S), 1) << @truncate(i);
        }

        result = sum;
    }
    return .{ result, s };
}

const Disk = struct {
    const Self = @This();
    const bit_size: usize = 64;
    data: List(u64),
    capacity: usize,
    size: usize,
    fn init(allocator: Allocator, capacity: usize) !Self {
        return .{
            .data = try List(u64).initCapacity(allocator, capacity >> 8),
            .capacity = capacity,
            .size = 0,
        };
    }

    fn deinit(self: *Self) void {
        self.data.deinit();
    }

    fn append(self: *Self, n: u64, l: u7) !void {
        const starting_offset = self.size % bit_size;
        if (self.size == self.capacity) return;
        var num = n;
        var len = l;
        if (self.size + len > self.capacity) {
            const new_len = self.capacity - self.size;
            num >>= @truncate(l - new_len);
            len = @truncate(new_len);
            self.size = self.capacity;
        } else {
            self.size += len;
        }

        if (self.data.items.len == 0 or starting_offset == 0) {
            try self.data.append(num << @truncate(bit_size - len));
            return;
        }

        const new_offset = starting_offset + len;
        var i = self.data.items.len - 1;

        if (new_offset == bit_size) {
            self.data.items[i] |= num;
            return;
        }

        if (new_offset < bit_size) {
            self.data.items[i] |= num << @truncate(bit_size - starting_offset - len);
            return;
        }

        if (new_offset > bit_size) {
            self.data.items[i] |= num >> @truncate(len - (bit_size - starting_offset));
            try self.data.append(num << @truncate(bit_size + bit_size - starting_offset - len));
            return;
        }
    }

    fn reverseInverse(self: Self) !Self {
        var disk = try Disk.init(self.data.allocator, self.capacity);
        {
            var inverse = ~self.data.getLast();
            const len: u6 = @truncate(self.size % bit_size);
            const offset: u6 = @truncate(bit_size - len);
            inverse >>= offset;
            var reverse: u64 = 0;
            for (0..len) |_| {
                reverse <<= 1;
                reverse |= inverse & 1;
                inverse >>= 1;
            }
            try disk.append(reverse, len);
        }
        if (self.data.items.len > 1) {
            for (2..self.data.items.len + 1) |i| {
                var inverse = ~self.data.items[self.data.items.len - i];
                var reverse: u64 = 0;
                for (0..bit_size) |_| {
                    reverse <<= 1;
                    reverse |= inverse & 1;
                    inverse >>= 1;
                }
                try disk.append(reverse, bit_size);
            }
        }

        return disk;
    }

    fn intoChecksum(self: *Self) !void {
        var sum = try Disk.init(self.data.allocator, self.capacity);
        const mask = 0b11;
        {
            for (0..self.data.items.len - 1) |i| {
                const item = self.data.items[i];
                for (1..bit_size / 2 + 1) |j| {
                    const pair = (item >> @truncate(bit_size - j * 2)) & mask;
                    if (pair == 0b11 or pair == 0b00) {
                        try sum.append(1, 1);
                    } else {
                        try sum.append(0, 1);
                    }
                }
            }
            {
                const item = self.data.getLast();
                const len = if (self.size % bit_size == 0) bit_size else self.size % bit_size;

                for (1..len / 2 + 1) |j| {
                    const pair = (item >> @truncate(bit_size - j * 2)) & mask;
                    if (pair == 0b11 or pair == 0b00) {
                        try sum.append(1, 1);
                    } else {
                        try sum.append(0, 1);
                    }
                }
            }
            self.deinit();
            self.* = sum;
        }
        while (self.size & 1 == 0) {
            sum = try Disk.init(self.data.allocator, self.capacity);
            for (0..self.data.items.len - 1) |i| {
                const item = self.data.items[i];
                for (1..bit_size / 2 + 1) |j| {
                    const pair = (item >> @truncate(bit_size - j * 2)) & mask;
                    if (pair == 0b11 or pair == 0b00) {
                        try sum.append(1, 1);
                    } else {
                        try sum.append(0, 1);
                    }
                }
            }
            {
                const item = self.data.getLast();
                const len = if (self.size % bit_size == 0) bit_size else self.size % bit_size;

                for (1..len / 2 + 1) |j| {
                    const pair = (item >> @truncate(bit_size - j * 2)) & mask;
                    if (pair == 0b11 or pair == 0b00) {
                        try sum.append(1, 1);
                    } else {
                        try sum.append(0, 1);
                    }
                }
            }
            self.deinit();
            self.* = sum;
        }
    }

    fn fillDisk(self: *Self) !void {
        while (self.size < self.capacity) {
            var b = try self.reverseInverse();
            defer b.deinit();
            try self.append(0, 1);
            for (b.data.items[0 .. b.data.items.len - 1]) |item| {
                try self.append(item, bit_size);
            }
            try self.append(b.data.getLast() >> @truncate(bit_size - b.size % bit_size), @truncate(b.size % bit_size));
        }
    }

    fn print(self: Self) void {
        var i: usize = 0;
        while (i < self.size) {
            if (self.size - i >= bit_size) {
                std.debug.print("{b:0>64}", .{self.data.items[i / bit_size]});
                i += bit_size;
            } else {
                for (0..self.size - i) |j| {
                    std.debug.print("{b}", .{self.data.items[i / bit_size] >> @truncate(bit_size - j - 1) & 1});
                }
                break;
            }
        }
    }
};

fn part1(comptime S: usize, input: U(S), input_len: usize) struct { U(S), usize } {
    const disk = fillDisk(S, input, input_len);
    return checksum(S, disk);
}

fn part2(alloc: Allocator, input: u64, input_len: u7) !Disk {
    var disk2 = try Disk.init(alloc, 35651584);
    try disk2.append(input, input_len);
    try disk2.fillDisk();
    try disk2.intoChecksum();
    return disk2;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const p1 = part1(272, 0b11101000110010100, 17);
    const p1_time = timer.read();
    for (0..p1[1]) |i| {
        print("{d}", .{(p1[0] >> @truncate(p1[1] - i - 1)) & 1});
    }
    print(" {d}ns\n", .{p1_time});
    timer.reset();

    var disk2 = try part2(gpa, 0b11101000110010100, 17);
    const p2_time = timer.read();
    defer disk2.deinit();
    disk2.print();
    print(" {d}ns\n", .{p2_time});
}

test "part2" {
    var disk2 = try part2(std.testing.allocator, 0b11101000110010100, 17);
    disk2.deinit();
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
