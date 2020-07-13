# bench-tcp-libs
Benchmarking tcp libs like ZeroMQ and Nanomsg by c and zig

# Install
```
sudo apt-get install libczmq-dev -y
```

# Benchmarking
## ZeroMQ by c
```
gcc -o c/bench-zeromq c/bench-zeromq.c -lczmq
./c/bench-zeromq
BenchmarkZeroMQ-C:   76280   7628 loops/s   131095 ns/op
```

## ZeroMQ by zig
```
zig build -Drelease-fast=true
./zig-cache/bin/bench-tcp
BenchmarkZeroMQ-Zig:   48232   4823 loops/s   207331 ns/op
```
