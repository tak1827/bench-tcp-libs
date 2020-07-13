const std = @import("std");
const time = std.time;
const warn = std.debug.warn;
const c = @cImport({
  @cInclude("czmq.h");
});

// ZeroMQ
var push: ?*c.zsock_t = undefined;
var pull: ?*c.zsock_t = undefined;
// 1400 length
const message = "HelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHello";

pub fn main() !void {
  push = c.zsock_new_push("@tcp://127.0.0.1:5560");
  pull = c.zsock_new_pull(">tcp://127.0.0.1:5560");

  const benchtime = time.ns_per_s * 10; // 10s
  // const benchtime = time.ns_per_s; // 1s
  try bench("BenchmarkZeroMQ-Zig", pushPull, benchtime);

  c.zsock_destroy(&pull);
  c.zsock_destroy(&push);
}

pub fn bench(comptime name: []const u8, F: var, benchtime: comptime_int) !void {
  var timer = try time.Timer.start();

  var loops: usize = 0;
  while (timer.read() < benchtime) : (loops += 1) {
    _ = F();
  }

  const loopPerS = loops * time.ns_per_s / benchtime;
  const timePerOp = benchtime / loops;
  warn("{}:   {}   {} loops/s   {} ns/op\n", .{ name, loops, loopPerS, timePerOp });
}

pub fn pushPull() void {
  _ = c.zstr_send(push, message);
  var string = c.zstr_recv(pull);
  c.zstr_free(&string);
}
