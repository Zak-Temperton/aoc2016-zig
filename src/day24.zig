const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Timer = std.time.Timer;
const tokenize = std.mem.tokenizeAny;
const print = std.debug.print;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day24.txt");

pub fn main() !void {
    var timer = try Timer.start();
    const p1 = try part1(gpa);
    const p1_time = timer.read();
    const p2 = try part2(gpa);
    const p2_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    print("{d} {d}ns\n", .{ p2, p2_time });
}

fn part1(alloc: Allocator) !usize {
    var map = List([]const bool).init(alloc);
    defer {
        for (map.items) |item| alloc.free(item);
        map.deinit();
    }
    var nums: [8][2]u8 = .{ .{ 0, 0 }, .{ 0, 0 }, .{ 0, 0 }, .{ 0, 0 }, .{ 0, 0 }, .{ 0, 0 }, .{ 0, 0 }, .{ 0, 0 } };
    var lines = tokenize(u8, data, "\r\n");
    var y: u8 = 0;
    while (lines.next()) |line| {
        var row = List(bool).init(alloc);
        var x: u8 = 0;
        for (line) |c| {
            try row.append(c == '#');
            if (c >= '0' and c <= '9') {
                nums[c - '0'] = .{ x, y };
            }
            x += 1;
        }
        try map.append(try row.toOwnedSlice());
        y += 1;
    }
    var paths = List([]usize).init(alloc);
    defer {
        for (paths.items) |item| alloc.free(item);
        paths.deinit();
    }
    for (0..nums.len) |i| {
        var map_clone = try List([]bool).initCapacity(alloc, map.items.len);
        defer {
            for (map_clone.items) |item| alloc.free(item);
            map_clone.deinit();
        }
        for (map.items) |row| {
            try map_clone.append(try alloc.dupe(bool, row[0..]));
        }
        try paths.append(try bfsb(alloc, &map_clone, &nums, i));
    }

    var perm: [8]u8 = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7 };
    var min: usize = followPath(paths.items, &perm);
    nextPermutation(&perm);
    while (perm[0] == 0) : (nextPermutation(&perm)) {
        var sum: usize = followPath(paths.items, &perm);
        if (sum <= min) {
            min = sum;
        }
    }
    return min;
}

fn part2(alloc: Allocator) !usize {
    var map = List([]const bool).init(alloc);
    defer {
        for (map.items) |item| alloc.free(item);
        map.deinit();
    }
    var nums: [8][2]u8 = .{ .{ 0, 0 }, .{ 0, 0 }, .{ 0, 0 }, .{ 0, 0 }, .{ 0, 0 }, .{ 0, 0 }, .{ 0, 0 }, .{ 0, 0 } };
    var lines = tokenize(u8, data, "\r\n");
    var y: u8 = 0;
    while (lines.next()) |line| {
        var row = List(bool).init(alloc);
        var x: u8 = 0;
        for (line) |c| {
            try row.append(c == '#');
            if (c >= '0' and c <= '9') {
                nums[c - '0'] = .{ x, y };
            }
            x += 1;
        }
        try map.append(try row.toOwnedSlice());
        y += 1;
    }
    var paths = List([]usize).init(alloc);
    defer {
        for (paths.items) |item| alloc.free(item);
        paths.deinit();
    }
    for (0..nums.len) |i| {
        var map_clone = try List([]bool).initCapacity(alloc, map.items.len);
        defer {
            for (map_clone.items) |item| alloc.free(item);
            map_clone.deinit();
        }
        for (map.items) |row| {
            try map_clone.append(try alloc.dupe(bool, row[0..]));
        }
        try paths.append(try bfsb(alloc, &map_clone, &nums, i));
    }

    var perm: [8]u8 = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7 };
    var min: usize = followReturnPath(paths.items, &perm);
    nextPermutation(&perm);
    while (perm[0] == 0) : (nextPermutation(&perm)) {
        var sum: usize = followReturnPath(paths.items, &perm);
        if (sum <= min) {
            min = sum;
        }
    }
    return min;
}

fn followPath(paths: [][]usize, perm: []u8) usize {
    if (perm.len == 1) return 0;
    return paths[perm[0]][perm[1]] + followPath(paths, perm[1..]);
}

fn followReturnPath(paths: [][]usize, perm: []u8) usize {
    if (perm.len == 1) return paths[perm[0]][0];
    return paths[perm[0]][perm[1]] + followReturnPath(paths, perm[1..]);
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

fn bfsb(all: Allocator, map: *List([]bool), nums: [][2]u8, i: usize) ![]usize {
    var next = List([2]u8).init(all);
    defer next.deinit();
    try next.append(nums[i]);
    map.items[nums[i][1]][nums[i][0]] = true;
    var result = try all.alloc(usize, nums.len);
    var count: usize = 0;
    var steps: usize = 0;
    while (next.items.len != 0 and count < nums.len) {
        var next_next = List([2]u8).init(all);
        errdefer next_next.deinit();
        for (next.items) |item| {
            for (nums, 0..) |num, j| {
                if (item[0] == num[0] and item[1] == num[1]) {
                    count += 1;
                    result[j] = steps;
                }
            }

            var up: [2]u8 = .{ item[0], item[1] + 1 };
            var down: [2]u8 = .{ item[0], item[1] - 1 };
            var right: [2]u8 = .{ item[0] + 1, item[1] };
            var left: [2]u8 = .{ item[0] - 1, item[1] };
            if (!map.items[up[1]][up[0]]) {
                map.items[up[1]][up[0]] = true;
                try next_next.append(up);
            }
            if (!map.items[down[1]][down[0]]) {
                map.items[down[1]][down[0]] = true;
                try next_next.append(down);
            }
            if (!map.items[right[1]][right[0]]) {
                map.items[right[1]][right[0]] = true;
                try next_next.append(right);
            }
            if (!map.items[left[1]][left[0]]) {
                map.items[left[1]][left[0]] = true;
                try next_next.append(left);
            }
        }
        next.deinit();
        next = next_next;
        steps += 1;
    }
    return result;
}

test "part1" {
    _ = try part1(std.testing.allocator);
}

test "part2" {
    _ = try part2(std.testing.allocator);
}
