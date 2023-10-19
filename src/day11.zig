const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const Timer = std.time.Timer;
const print = std.debug.print;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day11.txt");

fn U(comptime size: usize) type {
    return @Type(.{ .Int = .{
        .signedness = std.builtin.Signedness.unsigned,
        .bits = size,
    } });
}

const Part = enum { Part1, Part2 };

fn FacilityStateGeneric(comptime part: Part) type {
    const mask_size = if (part == .Part1) 5 else 7;
    const mask_perm_count = mask_size * (mask_size * 2 + 1);
    const Mask: type = U(mask_size);
    const Mask2: type = U(mask_size * 2);
    const Floors: type = comptime [4]Mask;
    return struct {
        const Self = @This();

        elevator: u3,
        min_floor: u3,
        chips: Floors,
        generators: Floors,

        fn init() Self {
            if (part == .Part1) {
                return .{
                    .elevator = 0,
                    .min_floor = 0,
                    .chips = Floors{ 0b10000, 0b01100, 0b00011, 0b00000 },
                    .generators = Floors{ 0b11100, 0b00000, 0b00011, 0b00000 },
                };
            } else {
                return .{
                    .elevator = 0,
                    .min_floor = 0,
                    .chips = Floors{ 0b1000011, 0b0110000, 0b0001100, 0b0000000 },
                    .generators = Floors{ 0b1110011, 0b0000000, 0b0001100, 0b0000000 },
                };
            }
        }

        fn equal(self: Self, other: Self) bool {
            return self.elevator == other.elevator and self.chips == other.chips and self.generators == other.generators;
        }

        fn valid(self: Self) bool {
            for (self.chips, self.generators) |i, j| {
                const a = i & j;
                const axi = a ^ i;
                const axj = a ^ j;
                if (axi != 0 and axj != 0) return false;
            }
            return true;
        }

        fn nextPerms(self: Self, seen: *Map(u64, void), perms: *List(Self)) !bool {
            for (comptime permBitsGen()) |mask| {
                const chip_mask: Mask = @truncate(mask >> mask_size);
                const gen_mask: Mask = @truncate(mask);

                if ((self.chips[self.elevator] & chip_mask == chip_mask) and (self.generators[self.elevator] & gen_mask == gen_mask)) {
                    if (self.elevator < 3) {
                        var perm = self;
                        perm.elevator += 1;
                        perm.chips[perm.elevator] |= chip_mask;
                        perm.chips[self.elevator] ^= chip_mask;
                        perm.generators[perm.elevator] |= gen_mask;
                        perm.generators[self.elevator] ^= gen_mask;
                        if (perm.chips[perm.min_floor] == 0 and perm.generators[perm.min_floor] == 0) {
                            perm.min_floor += 1;
                        }

                        if (~perm.chips[3] == 0 and ~perm.generators[3] == 0) {
                            return true;
                        }
                        if (!seen.contains(perm.hash()) and perm.valid()) {
                            try seen.put(perm.hash(), {});
                            try perms.append(perm);
                        }
                    }
                    if (self.elevator > self.min_floor and @popCount(mask) == 1) {
                        var perm = self;
                        perm.elevator -= 1;
                        perm.chips[perm.elevator] |= chip_mask;
                        perm.chips[self.elevator] ^= chip_mask;
                        perm.generators[perm.elevator] |= gen_mask;
                        perm.generators[self.elevator] ^= gen_mask;
                        if (~perm.chips[3] == 0 and ~perm.generators[3] == 0) {
                            return true;
                        }
                        if (!seen.contains(perm.hash()) and perm.valid()) {
                            try seen.put(perm.hash(), {});
                            try perms.append(perm);
                        }
                    }
                }
            }

            return false;
        }

        fn hash(self: Self) u64 {
            var res: u64 = 0;
            for (self.chips) |chip| {
                res = (res << mask_size) | chip;
            }
            for (self.generators) |gen| {
                res = (res << mask_size) | gen;
            }
            res = (res << 3) | self.elevator;
            res = (res << 3) | self.min_floor;
            return res;
        }

        fn permBitsGen() [mask_perm_count]Mask2 {
            const T2 = U(mask_size - 1);
            const bits: Mask2 = mask_size * 2;
            const one: Mask2 = 1;
            var res: [mask_perm_count]Mask2 = undefined;
            var i: Mask2 = 0;
            res[i] = one;
            var a: T2 = 1;
            while (a < bits) : (a += 1) {
                const n: Mask2 = one << a;
                i += one;
                res[i] = n;
                var b: T2 = 0;
                while (b < a) : (b += 1) {
                    i += one;
                    res[i] = n | (one << b);
                }
            }
            return res;
        }
    };
}

fn solve(comptime part: Part, alloc: Allocator) !usize {
    var map = Map(u64, void).init(alloc);
    defer map.deinit();
    var perms = List(FacilityStateGeneric(part)).init(alloc);
    defer perms.deinit();
    try perms.append(FacilityStateGeneric(part).init());
    var i: usize = 0;
    while (perms.items.len != 0) : (i += 1) {
        var newPerms = List(FacilityStateGeneric(part)).init(alloc);
        for (perms.items) |perm| {
            if (try perm.nextPerms(&map, &newPerms)) {
                return i + 1;
            }
        }
        perms.deinit();
        perms = newPerms;
    }
    return 0;
}

pub fn main() !void {
    var timer = try Timer.start();
    const p1 = try solve(.Part1, gpa);
    const p1_time = timer.read();
    print("{d} {d}ns\n", .{ p1, p1_time });
    timer.reset();
    const p2 = try solve(.Part2, gpa);
    const p2_time = timer.read();
    print("{d} {d}ns\n", .{ p2, p2_time });
}

test "part1" {
    _ = try solve(.Part1, std.testing.allocator);
}

test "part2" {
    _ = try solve(.Part2, std.testing.allocator);
}
