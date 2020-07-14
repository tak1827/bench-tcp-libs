const std = @import("std");
const time = std.time;
const warn = std.debug.warn;
const panic = std.debug.panic;
const mem = std.mem;
const c = @cImport({
  @cInclude("czmq.h");
  @cInclude("nng/nng.h");
  @cInclude("nng/protocol/pipeline0/pull.h");
  @cInclude("nng/protocol/pipeline0/push.h");
  @cInclude("sys/random.h");
});

// 1400 length
const message = "HelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHello";

// ZeroMQ
var push: ?*c.zsock_t = undefined;
var pull: ?*c.zsock_t = undefined;

// nng
const url = "tcp://127.0.0.1:5560";


pub fn main() !void {
  const allocator = std.testing.allocator;
  const lib = try std.process.getEnvVarOwned(allocator, "TCP_LIB");

  // const benchtime = time.ns_per_s * 10; // 10s
  const benchtime = time.ns_per_s; // 1s

  // bench of ZeroMQ
  if (mem.eql(u8, lib, "ZeroMQ")) {
    push = c.zsock_new_push("@tcp://127.0.0.1:5560");
    pull = c.zsock_new_pull(">tcp://127.0.0.1:5560");

    try bench("BenchmarkZeroMQ-Zig", pushPull, benchtime);

    c.zsock_destroy(&pull);
    c.zsock_destroy(&push);

  // run nng server
  } else if (mem.eql(u8, lib, "nng-server")) {

    var sock: c.nng_socket = undefined;

    if (c.nng_pull0_open(&sock) != 0) {
      panic("failed to open pull", .{});
    }
    if (c.nng_listen(sock, url, null, 0) != 0) {
      panic("failed to listen", .{});
    }

    warn("listening: {}\n", .{ url });

    while(true) {
      var buf: []u8 = undefined;
      var sz: usize = undefined;
      if (c.nng_recv(sock, &buf, &sz, c.NNG_FLAG_ALLOC) != 0) {
        panic("failed to recv", .{});
      }
      warn("server: recv, {}", .{ buf });
      c.nng_free(@ptrCast(*c_void, buf), sz);
    }

  // bench of nng
  } else if (mem.eql(u8, lib, "nng-bench")) {

  // no bench
  } else {
    warn("no benchmarking\n", .{});
  }

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
