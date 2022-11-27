Idiomatic [zig] bindings for [fcft].

## Dependencies

-   [zig] 0.10
-   [fcft] 3.0.1
-   [zig-pixman]

## Usage

See the [example] repo for a more complete help.

`build.zig` example:

```zig
const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("foo", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    const pixman = std.build.Pkg{
        .name = "pixman",
        .path = .{ .path = "deps/zig-pixman/pixman.zig" },
    };
    exe.addPackage(pixman);
    exe.linkSystemLibrary("pixman-1");

    const fcft = std.build.Pkg{
        .name = "fcft",
        .path = .{ .path = "deps/zig-fcft/fcft.zig" },
        .dependencies = &[_]std.build.Pkg{pixman},
    };
    exe.addPackage(fcft);
    exe.linkSystemLibrary("fcft");

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
```

## Contributing

See [CONTRIBUTING.md]

## Acknowledgement

Started with a fork of https://git.sr.ht/~andreafeletto/zig-fcft

## License

zig-fcft is licensed under the [MIT] license.

[zig]: https://ziglang.org/download/
[fcft]: https://codeberg.org/dnkl/fcft
[zig-pixman]: https://github.com/ifreund/zig-pixman
[example]: https://git.sr.ht/~novakane/zig-fcft-example
[contributing.md]: CONTRIBUTING.md
[mit]: COPYING
