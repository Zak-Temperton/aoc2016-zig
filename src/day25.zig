const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day25.txt");

const Register = union(enum) {
    const Self = @This();

    val: i64,
    reg: u8,

    fn from(r: []const u8) !Self {
        switch (r[0]) {
            'a'...'z' => |c| {
                return .{ .reg = c - 'a' };
            },
            else => {
                return .{ .val = try parseInt(i64, r, 10) };
            },
        }
    }
};

const Instruction = union(enum) {
    const two_args = struct { a: Register, b: Register };
    const one_arg = struct { a: Register };
    const Self = @This();

    cpy: two_args,
    jnz: two_args,
    out: one_arg,
    inc: one_arg,
    dec: one_arg,
};

fn parseLine(input: []const u8) ?Instruction {
    var words = tokenize(u8, input, " ");
    var result: ?Instruction = null;
    switch (words.next().?[0]) {
        'c' => {
            const a = Register.from(words.next().?) catch return null;
            const b = Register.from(words.next().?) catch return null;
            result = .{ .cpy = .{ .a = a, .b = b } };
        },
        'j' => {
            const a = Register.from(words.next().?) catch return null;
            const b = Register.from(words.next().?) catch return null;
            result = .{ .jnz = .{ .a = a, .b = b } };
        },
        'o' => {
            const a = Register.from(words.next().?) catch return null;
            result = .{ .out = .{ .a = a } };
        },
        'd' => {
            const a = Register.from(words.next().?) catch return null;
            result = .{ .dec = .{ .a = a } };
        },
        'i' => {
            const a = Register.from(words.next().?) catch return null;
            result = .{ .inc = .{ .a = a } };
        },
        else => {
            return null;
        },
    }
    return result;
}

fn run(alloc: Allocator, instructions: []Instruction, input: i64) !bool {
    var registers: [4]i64 = .{ input, 0, 0, 0 };
    var out = List(i64).init(alloc);
    defer out.deinit();
    var index: usize = 0;
    var expect: i64 = 0;
    while (index < instructions.len) {
        switch (instructions[index]) {
            .cpy => |instr| {
                const in = switch (instr.a) {
                    .reg => |r| registers[r],
                    .val => |v| v,
                };
                switch (instr.b) {
                    .reg => |r| registers[r] = in,
                    .val => {},
                }
                index += 1;
            },
            .jnz => |instr| {
                const in = switch (instr.a) {
                    .reg => |r| registers[r],
                    .val => |v| v,
                };
                if (in != 0) {
                    switch (instr.b) {
                        .reg => |r| {
                            if (registers[r] < 0) {
                                index -= @intCast(-registers[r]);
                            } else {
                                index += @intCast(registers[r]);
                            }
                        },
                        .val => |v| {
                            if (v < 0) {
                                index -= @intCast(-v);
                            } else {
                                index += @intCast(v);
                            }
                        },
                    }
                } else {
                    index += 1;
                }
            },
            .out => |instr| {
                try out.append(switch (instr.a) {
                    .reg => |r| registers[r],
                    .val => |v| v,
                });
                if (out.getLast() != expect) return true;
                expect ^= 1;
                if (registers[0] == 0) return false;

                index += 1;
            },
            .dec => |instr| {
                switch (instr.a) {
                    .reg => |r| registers[r] -= 1,
                    .val => {},
                }

                index += 1;
            },
            .inc => |instr| {
                switch (instr.a) {
                    .reg => |r| registers[r] += 1,
                    .val => {},
                }
                index += 1;
            },
        }
    }
    return true;
}

fn solve(alloc: Allocator) !i64 {
    var instructions = List(Instruction).init(alloc);
    defer instructions.deinit();

    var lines = tokenize(u8, data, "\r\n");
    while (lines.next()) |line| {
        try instructions.append(parseLine(line).?);
    }
    var i: i64 = 0;
    while (try run(alloc, instructions.items, i)) : (i += 1) {}
    return i;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const p1 = try solve();
    const p1_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
}

test "solve" {
    _ = try solve(std.testing.allocator);
}

// Useful stdlib functions
const tokenize = std.mem.tokenizeAny;
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
