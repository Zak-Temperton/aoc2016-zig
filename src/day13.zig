const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day13.txt");

fn formula(x: u64, y: u64, n: u64) bool {
    const num = x * (x + y + y + 3) + y * (y + 1) + n;
    const pop = @popCount(num);
    return pop & 1 == 1;
}

const Maze = struct {
    const Self = @This();

    maze: [64]u64,
    num: u64,

    fn init(num: usize) Self {
        return .{
            .maze = [_]u64{0} ** 64,
            .num = num,
        };
    }

    fn setWall(self: *Self, x: u6, y: u6) void {
        self.maze[y] |= @as(u64, 1) << x;
    }

    fn isWall(self: *Self, x: u6, y: u6) bool {
        if (self.maze[y] & (@as(u64, 1) << x) == 0) {
            if (formula(@as(u64, x), @as(u64, y), self.num)) {
                self.setWall(x, y);
                return true;
            }
            return false;
        } else {
            return true;
        }
    }

    fn bfs(self: *Self, alloc: Allocator, tx: u6, ty: u6) !?usize {
        const PosList = List(struct { x: u6, y: u6 });
        var next = PosList.init(alloc);
        defer next.deinit();
        var new_next: PosList = undefined;
        try next.append(.{ .x = 1, .y = 1 });
        self.setWall(1, 1);

        var steps: usize = 0;
        while (next.items.len != 0) : (steps += 1) {
            new_next = PosList.init(alloc);
            for (next.items) |pos| {
                const x = pos.x;
                const y = pos.y;
                if (x == tx and y == ty) {
                    new_next.deinit();
                    return steps;
                }

                if (x != 63 and !self.isWall(x + 1, y)) {
                    self.setWall(x + 1, y);
                    try new_next.append(.{ .x = x + 1, .y = y });
                }
                if (x != 0 and !self.isWall(x - 1, y)) {
                    self.setWall(x - 1, y);
                    try new_next.append(.{ .x = x - 1, .y = y });
                }
                if (y != 63 and !self.isWall(x, y + 1)) {
                    self.setWall(x, y + 1);
                    try new_next.append(.{ .x = x, .y = y + 1 });
                }
                if (y != 0 and !self.isWall(x, y - 1)) {
                    self.setWall(x, y - 1);
                    try new_next.append(.{ .x = x, .y = y - 1 });
                }
            }
            next.deinit();
            next = new_next;
        }

        return null;
    }

    fn bfs50(self: *Self, alloc: Allocator) !usize {
        const PosList = List(struct { x: u6, y: u6 });
        var next = PosList.init(alloc);
        defer next.deinit(); //deinits next and new_next
        var new_next: PosList = undefined;
        try next.append(.{ .x = 1, .y = 1 });
        self.setWall(1, 1);

        var count: usize = 0;

        var steps: usize = 0;
        while (steps <= 50 and next.items.len != 0) : (steps += 1) {
            new_next = PosList.init(alloc);
            for (next.items) |pos| {
                const x = pos.x;
                const y = pos.y;
                count += 1;

                if (x != 63 and !self.isWall(x + 1, y)) {
                    self.setWall(x + 1, y);
                    try new_next.append(.{ .x = x + 1, .y = y });
                }
                if (x != 0 and !self.isWall(x - 1, y)) {
                    self.setWall(x - 1, y);
                    try new_next.append(.{ .x = x - 1, .y = y });
                }
                if (y != 63 and !self.isWall(x, y + 1)) {
                    self.setWall(x, y + 1);
                    try new_next.append(.{ .x = x, .y = y + 1 });
                }
                if (y != 0 and !self.isWall(x, y - 1)) {
                    self.setWall(x, y - 1);
                    try new_next.append(.{ .x = x, .y = y - 1 });
                }
            }
            next.deinit();
            next = new_next;
        }

        return count;
    }
};

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var maze = Maze.init(1352);
    const part1 = (try maze.bfs(gpa, 31, 39)).?;
    const part1_time = timer.read();
    print("{d} {d}ns\n", .{ part1, part1_time });
    timer.reset();
    var maze2 = Maze.init(1352);
    const part2 = try maze2.bfs50(gpa);
    const part2_time = timer.read();
    print("{d} {d}ns\n", .{ part2, part2_time });
}

test "part1" {
    var maze = Maze.init(1352);
    _ = (try maze.bfs(std.testing.allocator, 31, 39)).?;
}
test "part2" {
    var maze = Maze.init(1352);
    _ = try maze.bfs50(std.testing.allocator);
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
