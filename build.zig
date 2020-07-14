const Builder = @import("std").build.Builder;
const builtin = @import("builtin");

pub fn build(b: *Builder) void {
  const mode = b.standardReleaseOptions();
  const exe = b.addExecutable("bench-tcp", "zig/main.zig");
  exe.setBuildMode(mode);

  // -target mipsel-linux.4.10-gnu.2.1
  // exe.setTarget(.{
  //     .cpu_arch = .x86_64,
  //     .os_tag = .linux,
  //     .abi = .gnu,
  // });

  exe.linkSystemLibrary("c");
  exe.linkSystemLibrary("util");
  exe.linkSystemLibrary("czmq");
  exe.linkSystemLibrary("nng");
  exe.install();

  const run_cmd = exe.run();

  const run_step = b.step("run", "Run the app");
  run_step.dependOn(&run_cmd.step);

  b.default_step.dependOn(&exe.step);
  b.installArtifact(exe);
}
