const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Timer = std.time.Timer;
const print = std.debug.print;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day12.txt");

const Register = u8;

const Input = union(enum) {
    Register: Register,
    Number: u32,
};

const Instruction = union(enum) {
    Inc: Register,
    Dec: Register,
    Copy: struct { input: Input, target: Register },
    Jump: struct { input: Input, target: union(enum) { Pos: u32, Neg: u32 } },
};

fn nomInt(input: []const u8, i: *usize) u32 {
    var int: u32 = 0;
    while (i.* < input.len and input[i.*] >= '0' and input[i.*] <= '9') : (i.* += 1) {
        int = int * 10 + @as(u32, input[i.*] - '0');
    }
    return int;
}

fn parseData(alloc: Allocator) !List(Instruction) {
    var instructions = List(Instruction).init(alloc);
    var i: usize = 0;

    while (i < data.len - 1) {
        switch (data[i]) {
            'i' => {
                const instr = Instruction{ .Inc = data[i + 4] - 'a' };
                i += 7;
                try instructions.append(instr);
            },
            'd' => {
                const instr = Instruction{ .Dec = data[i + 4] - 'a' };
                i += 7;
                try instructions.append(instr);
            },
            'c' => {
                i += 4;
                var input: Input = undefined;
                if (data[i] >= 'a' and data[i] <= 'd') {
                    input = Input{ .Register = data[i] - 'a' };
                    i += 2;
                } else {
                    input = Input{ .Number = nomInt(data, &i) };
                    i += 1;
                }
                const target = data[i] - 'a';
                i += 3;
                try instructions.append(Instruction{ .Copy = .{ .input = input, .target = target } });
            },
            'j' => {
                i += 4;
                var input: Input = undefined;
                if (data[i] >= 'a' and data[i] <= 'd') {
                    input = Input{ .Register = data[i] - 'a' };
                    i += 2;
                } else {
                    input = Input{ .Number = nomInt(data, &i) };
                    i += 1;
                }

                try instructions.append(Instruction{ .Jump = .{
                    .input = input,
                    .target = if (data[i] == '-') blk: {
                        i += 1;
                        break :blk .{ .Neg = @truncate(nomInt(data, &i)) };
                    } else .{ .Pos = @truncate(nomInt(data, &i)) },
                } });
                i += 2;
            },
            else => unreachable,
        }
    }

    return instructions;
}

const Computer = struct {
    const Self = @This();

    instructions: List(Instruction),
    registers: [4]u32,

    fn init(instructions: List(Instruction), registers: [4]u32) !Self {
        return .{
            .instructions = instructions,
            .registers = registers,
        };
    }

    fn run(self: *Self) u32 {
        var index: u32 = 0;
        while (index < self.instructions.items.len) {
            switch (self.instructions.items[index]) {
                .Inc => |register| {
                    self.registers[register] += 1;
                    index += 1;
                },
                .Dec => |register| {
                    self.registers[register] -= 1;
                    index += 1;
                },
                .Copy => |instruction| {
                    const input = switch (instruction.input) {
                        .Register => |register| self.registers[register],
                        .Number => |number| number,
                    };
                    self.registers[instruction.target] = input;
                    index += 1;
                },
                .Jump => |instruction| {
                    const input = switch (instruction.input) {
                        .Register => |register| self.registers[register],
                        .Number => |number| number,
                    };
                    if (input != 0) {
                        switch (instruction.target) {
                            .Pos => |num| index += num,
                            .Neg => |num| index -= num,
                        }
                    } else {
                        index += 1;
                    }
                },
            }
        }
        return self.registers[0];
    }
};

pub fn main() !void {
    var timer = try Timer.start();
    const instructions = try parseData(gpa);
    defer instructions.deinit();
    const setup_time = timer.lap();
    var computer = try Computer.init(instructions, [4]u32{ 0, 0, 0, 0 });
    const part1 = computer.run();
    const part1_time = timer.read();
    print("{d} {d}ns\n", .{ part1, setup_time + part1_time });
    timer.reset();
    var computer2 = try Computer.init(instructions, [4]u32{ 0, 0, 1, 0 });
    const part2 = computer2.run();
    const part2_time = timer.read();
    print("{d} {d}ns\n", .{ part2, setup_time + part2_time });
}

test "part1" {
    const instructions = try parseData(std.testing.allocator);
    defer instructions.deinit();
    var computer = try Computer.init(instructions, [4]u32{ 0, 0, 0, 0 });
    _ = computer.run();
}

test "part2" {
    const instructions = try parseData(std.testing.allocator);
    defer instructions.deinit();
    var computer2 = try Computer.init(instructions, [4]u32{ 0, 0, 1, 0 });
    _ = computer2.run();
}
