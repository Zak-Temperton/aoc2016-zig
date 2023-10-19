const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day10.txt");

const Target = union(enum) {
    Robot: usize,
    Output: usize,
};

const Robot = struct {
    const Self = @This();
    low: Target,
    high: Target,
    microchip: ?usize,

    fn init(low: Target, high: Target) Self {
        return .{
            .low = low,
            .high = high,
            .microchip = null,
        };
    }

    const Output = struct { target: Target, value: usize };

    fn receiveMicrochip(self: *Self, value: usize) ?struct { high: Output, low: Output } {
        if (self.microchip) |held| {
            if (held > value) {
                return .{
                    .low = .{ .target = self.low, .value = value },
                    .high = .{ .target = self.high, .value = held },
                };
            } else {
                return .{
                    .low = .{ .target = self.low, .value = held },
                    .high = .{ .target = self.high, .value = value },
                };
            }
        } else {
            self.microchip = value;
            return null;
        }
    }
};

fn nomInt(input: []const u8, i: *usize) usize {
    var int: usize = 0;
    while (i.* < input.len and input[i.*] >= '0' and input[i.*] <= '9') : (i.* += 1) {
        int = int * 10 + @as(usize, input[i.*] - '0');
    }
    return int;
}

const Factory = struct {
    const Self = @This();

    robots: List(Robot),
    output: List(usize),
    instructions: List(Instruction),

    const Instruction = struct { target: usize, value: usize };

    fn init(allocator: Allocator) Self {
        return .{
            .robots = List(Robot).init(allocator),
            .output = List(usize).init(allocator),
            .instructions = List(Instruction).init(allocator),
        };
    }

    fn deinit(self: *Self) void {
        self.robots.deinit();
        self.output.deinit();
        self.instructions.deinit();
    }

    fn initFrom(input: []const u8, allocator: Allocator) !Self {
        var self = Self.init(allocator);
        var i: usize = 0;
        while (i < data.len - 1) {
            //print("{d}\n", .{i});
            if (input[i] == 'b') {
                i += 4;
                const robot_index = nomInt(input, &i);

                i += 14;
                var low_target: Target = undefined;
                if (input[i] == 'b') {
                    i += 4;
                    const int = nomInt(input, &i);
                    low_target = Target{ .Robot = int };
                } else {
                    i += 7;
                    const int = nomInt(input, &i);
                    low_target = Target{ .Output = int };
                }
                i += 13;
                var high_target: Target = undefined;
                if (input[i] == 'b') {
                    i += 4;
                    const int = nomInt(input, &i);
                    high_target = Target{ .Robot = int };
                } else {
                    i += 7;
                    const int = nomInt(input, &i);
                    high_target = Target{ .Output = int };
                }
                const robot = Robot.init(low_target, high_target);
                try self.insertRobot(robot_index, robot);
            } else {
                i += 6;
                const value = nomInt(input, &i);
                i += 13;
                const targetBot = nomInt(input, &i);
                try self.instructions.append(.{ .target = targetBot, .value = value });
            }
            i += 2;
        }
        return self;
    }

    fn clone(self: *Self) Allocator.Error!Self {
        return .{
            .robots = try self.robots.clone(),
            .output = try self.output.clone(),
            .instructions = try self.instructions.clone(),
        };
    }

    fn insertRobot(self: *Self, index: usize, robot: Robot) !void {
        //print("robot index {d}\n", .{index});
        if (index >= self.robots.items.len) {
            try self.robots.appendNTimes(undefined, (index - self.robots.items.len) + 1);
        }
        self.robots.items[index] = robot;
    }

    fn insertOutput(self: *Self, index: usize, value: usize) !void {
        //print("output index {d}\n", .{index});
        if (index >= self.output.items.len) {
            try self.output.appendNTimes(undefined, (index - self.output.items.len) + 1);
        }
        self.output.items[index] = value;
    }

    fn giveValueToRobot(self: *Self, robot_index: usize, value: usize) !void {
        if (self.robots.items[robot_index].receiveMicrochip(value)) |output| {
            switch (output.low.target) {
                Target.Robot => |robot| try self.giveValueToRobot(robot, output.low.value),
                Target.Output => |out| try self.insertOutput(out, output.low.value),
            }
            switch (output.high.target) {
                Target.Robot => |robot| try self.giveValueToRobot(robot, output.high.value),
                Target.Output => |out| try self.insertOutput(out, output.high.value),
            }
        }
    }

    fn part1(self: *Self, comptime value1: usize, comptime value2: usize) !usize {
        for (self.instructions.items) |instruction| {
            if (try self.part1_helper(value1, value2, instruction.target, instruction.value)) |result| {
                return result;
            }
        }
        unreachable;
    }

    fn part1_helper(self: *Self, comptime value1: usize, comptime value2: usize, robot_index: usize, value: usize) !?usize {
        if (self.robots.items[robot_index].receiveMicrochip(value)) |output| {
            if ((value1 == output.low.value or value1 == output.high.value) and
                (value2 == output.low.value or value2 == output.high.value))
            {
                return robot_index;
            }
            switch (output.low.target) {
                Target.Robot => |robot| if (try self.part1_helper(value1, value2, robot, output.low.value)) |answer| return answer,
                Target.Output => |out| try self.insertOutput(out, output.low.value),
            }
            switch (output.high.target) {
                Target.Robot => |robot| if (try self.part1_helper(value1, value2, robot, output.high.value)) |answer| return answer,
                Target.Output => |out| try self.insertOutput(out, output.high.value),
            }
        }
        return null;
    }

    fn part2(self: *Self) !usize {
        for (self.instructions.items) |instruction| {
            try self.giveValueToRobot(instruction.target, instruction.value);
        }
        return self.output.items[0] * self.output.items[1] * self.output.items[2];
    }
};

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var factory = try Factory.initFrom(data, gpa);
    defer factory.deinit();
    const setup_time = timer.read();
    var factory2 = try factory.clone();
    defer factory2.deinit();
    timer.reset();

    const p1 = try factory.part1(61, 17);
    const p1_time = timer.read();

    print("{d} {d}ns\n", .{ p1, p1_time + setup_time });

    timer.reset();
    const p2 = try factory2.part2();
    const p2_time = timer.read();

    print("{d} {d}ns\n", .{ p2, p2_time + setup_time });
}

test "part1" {
    var factory = try Factory.initFrom(data, std.testing.allocator);
    defer factory.deinit();
    _ = try factory.part1(61, 17);
}
test "part2" {
    var factory = try Factory.initFrom(data, std.testing.allocator);
    defer factory.deinit();
    _ = try factory.part2();
}

// Useful stdlib functions
const tokenize = std.mem.tokenizeconst;
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
