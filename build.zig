const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) !void {
    _ = b.addModule("zig-fcft", .{
        .root_source_file = .{ .path = "fcft.zig" },
    });
}
