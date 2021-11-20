Idiomatic [Zig](https://ziglang.org/) bindings for
[fcft](https://codeberg.org/dnkl/fcft).

Fork of https://git.sr.ht/~andreafeletto/zig-fcft

# Dependencies

-   [zig](https://ziglang.org/) 0.8.1
-   [fcft](https://codeberg.org/dnkl/fcft) 2.5.0
-   [zig-pixman](https://github.com/ifreund/zig-pixman)

# Usage

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
        .path = "deps/zig-pixman/pixman.zig",
    };
    exe.addPackage(pixman);
    exe.linkSystemLibrary("pixman-1");

    const fcft = std.build.Pkg{
        .name = "fcft",
        .path = "deps/zig-fcft/fcft.zig",
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

# Contributing

For patches, questions or discussion send a [plain text] mail to my
[public inbox][] [~novakane/public-inbox@lists.sr.ht][] with project
prefix set to `zig-fcft`:

```
git config sendemail.to "~novakane/public-inbox@lists.sr.ht"
git config format.subjectPrefix "PATCH zig-fcft"
```

See [here] for some great resource on how to use `git send-email`
if you're not used to it, and my [wiki][].

[plain text]: https://useplaintext.email/
[public inbox]: https://lists.sr.ht/~novakane/public-inbox
[~novakane/public-inbox@lists.sr.ht]: mailto:~novakane/public-inbox@lists.sr.ht
[here]: https://git-send-email.io
[wiki]: https://man.sr.ht/~novakane/guides/

# License

[MIT][]

[mit]: LICENSE
