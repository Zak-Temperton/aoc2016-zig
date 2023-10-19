const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const parseInt = std.fmt.parseInt;
const tokenize = std.mem.tokenizeAny;
const print = std.debug.print;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day23.txt");

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
    tgl: one_arg,
    inc: one_arg,
    dec: one_arg,

    fn toggle(self: *Self) void {
        self.* = switch (self.*) {
            .cpy => |s| .{ .jnz = .{ .a = s.a, .b = s.b } },
            .jnz => |s| .{ .cpy = .{ .a = s.a, .b = s.b } },
            .tgl => |s| .{ .inc = .{ .a = s.a } },
            .dec => |s| .{ .inc = .{ .a = s.a } },
            .inc => |s| .{ .dec = .{ .a = s.a } },
        };
    }
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
        't' => {
            const a = Register.from(words.next().?) catch return null;
            result = .{ .tgl = .{ .a = a } };
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

fn solve(alloc: Allocator, input: i64) !i64 {
    var registers: [4]i64 = .{ input, 0, 0, 0 };
    var instructions = List(Instruction).init(alloc);
    defer instructions.deinit();
    var lines = tokenize(u8, data, "\r\n");
    while (lines.next()) |line| {
        try instructions.append(parseLine(line).?);
    }
    var index: usize = 0;
    while (index < instructions.items.len) {
        switch (instructions.items[index]) {
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
            .tgl => |instr| {
                const in = switch (instr.a) {
                    .reg => |r| registers[r],
                    .val => |v| v,
                };
                var target = index;
                if (in < 0) {
                    target -= @intCast(-in);
                } else {
                    target += @intCast(in);
                }
                if (target < instructions.items.len) instructions.items[target].toggle();
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
    return registers[0];
}
pub fn main() !void {
    var timer = try std.time.Timer.start();
    const p1 = try solve(gpa, 7);
    const p1_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    timer.reset();
    const p2 = try solve(gpa, 12);
    const p2_time = timer.read();
    print("{d} {d}ns\n", .{ p2, p2_time });
}

test "solve" {
    _ = try solve(std.testing.allocator, 7);
}
