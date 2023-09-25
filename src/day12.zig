const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

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

fn parseData(allo: Allocator) !List(Instruction) {
    var instructions = List(Instruction).init(allo);
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
    var timer = try std.time.Timer.start();
    const instructions = try parseData(gpa);
    const setup_time = timer.lap();
    defer instructions.deinit();
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
