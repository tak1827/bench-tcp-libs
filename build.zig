const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
  const mode = b.standardReleaseOptions();
  const exe = b.addExecutable("bench-tcp", "src/main.zig");
  exe.setBuildMode(mode);

  exe.linkSystemLibrary("c");
  exe.linkSystemLibrary("czmq");
  exe.install();

  const run_cmd = exe.run();

  const run_step = b.step("run", "Run the app");
  run_step.dependOn(&run_cmd.step);

  b.default_step.dependOn(&exe.step);
  b.installArtifact(exe);
}
