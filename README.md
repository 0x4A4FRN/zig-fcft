Idiomatic [zig] bindings for [fcft].

## Dependencies

-   [zig] 0.11
-   [fcft] 3.1.6
-   [zig-pixman]

## Usage

See the [example] repo for a more complete help.

`build.zig` example:

```zig
const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const pixman = b.createModule(.{ .source_file = .{ .path = "deps/zig-pixman/pixman.zig" } });
    const fcft = b.createModule(.{
        .source_file = .{ .path = "deps/zig-fcft/fcft.zig" },
        .dependencies = &.{
            .{ .name = "pixman", .module = pixman },
        },
    });

    const exe = b.addExecutable(.{
        .name = "foo",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.addModule("pixman", pixman);
    exe.addModule("fcft", fcft);

    exe.linkLibC();
    exe.linkSystemLibrary("pixman-1");
    exe.linkSystemLibrary("fcft");

    b.installArtifact(exe);
}
```

## Contributing

See [CONTRIBUTING.md]

## Acknowledgement

Started as a fork of https://git.sr.ht/~andreafeletto/zig-fcft

## License

zig-fcft is licensed under the [MIT] license.

[zig]: https://ziglang.org/download/
[fcft]: https://codeberg.org/dnkl/fcft
[zig-pixman]: https://github.com/ifreund/zig-pixman
[example]: https://git.sr.ht/~novakane/zig-fcft-example
[contributing.md]: CONTRIBUTING.md
[mit]: COPYING
