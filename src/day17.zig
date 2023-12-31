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

const data = @embedFile("data/day17.txt");

const hash = std.crypto.hash.Md5.hash;
const buf_len = std.crypto.hash.Md5.digest_length;
const bytesToHex = std.fmt.bytesToHex;

const State = struct {
    const Self = @This();

    x: u3,
    y: u3,
    path: List(u8),

    fn init(alloc: Allocator, input: []const u8) !Self {
        var result = Self{
            .path = List(u8).init(alloc),
            .x = 0,
            .y = 0,
        };
        errdefer result.path.deinit();
        try result.path.appendSlice(input);
        return result;
    }

    fn deinit(self: *Self) void {
        self.path.deinit();
    }

    fn add(self: Self, dir: u8) !Self {
        var result = try self.clone();
        try result.path.append(dir);
        switch (dir) {
            'U' => result.y -= 1,
            'D' => result.y += 1,
            'L' => result.x -= 1,
            'R' => result.x += 1,
            else => unreachable,
        }
        return result;
    }

    fn clone(self: Self) !Self {
        return .{
            .path = try self.path.clone(),
            .x = self.x,
            .y = self.y,
        };
    }

    fn getOpenDoors(state: State) !List(State) {
        var buf: [buf_len]u8 = undefined;
        hash(state.path.items, &buf, .{});
        const hex = bytesToHex(buf[0..2], .upper);
        var result = List(State).init(state.path.allocator);
        errdefer result.deinit();
        if (state.y != 0 and hex[0] > 'A' and hex[0] <= 'F') try result.append(try state.add('U'));
        if (state.y != 3 and hex[1] > 'A' and hex[1] <= 'F') try result.append(try state.add('D'));
        if (state.x != 0 and hex[2] > 'A' and hex[2] <= 'F') try result.append(try state.add('L'));
        if (state.x != 3 and hex[3] > 'A' and hex[3] <= 'F') try result.append(try state.add('R'));
        return result;
    }
};

fn bfs(alloc: Allocator, input: []const u8) ![]const u8 {
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    var init = try State.init(arena.allocator(), input);
    var next: List(State) = try init.getOpenDoors();
    while (next.items.len != 0) {
        var new_next = List(State).init(arena.allocator());
        errdefer new_next.deinit();

        for (next.items) |*item| {
            if (item.*.x == 3 and item.*.y == 3) return alloc.dupe(u8, (try item.path.toOwnedSlice())[input.len..]);
            var new = try item.getOpenDoors();
            try new_next.appendSlice(new.items);
            new.deinit();
        }
        next.deinit();
        next = new_next;
    }
    unreachable;
}

fn bfsLongest(alloc: Allocator, input: []const u8) !usize {
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    var steps: usize = 1;
    var next = try (try State.init(arena.allocator(), input)).getOpenDoors();
    var longest: usize = 0;

    while (next.items.len != 0) : (steps += 1) {
        var new_next = List(State).init(arena.allocator());
        errdefer new_next.deinit();

        for (next.items) |*item| {
            if (item.*.x == 3 and item.*.y == 3) {
                if (steps > longest) longest = steps;
                continue;
            }
            try new_next.appendSlice((try item.getOpenDoors()).items);
            item.deinit();
        }
        next.deinit();
        next = new_next;
    }
    return longest;
}

pub fn main() !void {
    var timer = try Timer.start();
    const p1 = try bfs(gpa, "ioramepc");
    const p1_time = timer.read();
    print("{s} {d}ns\n", .{ p1, p1_time });
    timer.reset();
    const p2 = try bfsLongest(gpa, "ioramepc");
    const p2_time = timer.read();
    print("{d} {d}ns\n", .{ p2, p2_time });
}

test "bfs" {
    var list = try bfs(std.testing.allocator, "ioramepc");
    std.testing.allocator.free(list);
}

test "bfsLongest" {
    _ = try bfsLongest(std.testing.allocator, "ioramepc");
}
