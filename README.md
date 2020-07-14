# bench-tcp-libs
Benchmarking tcp libs like ZeroMQ and nng by c and zig

# Install
```bash
// install ZeroMQ
sudo apt-get install libczmq-dev -y

// install build tools for nng
sudo apt install cmake -y
sudo apt install ninja-build -y

// install nng
wget https://github.com/nanomsg/nng/releases/tag/v1.3.0/nng-1.3.0.tar.gz
tar -zxvf nng-1.3.0.tar.gz
mkdir build
cd build
cmake -G Ninja ..
ninja
ninja test -> 1 test failed in my case: 41 - resolv (Failed)
ninja install
ldconfig
```

# Benchmarking
## ZeroMQ by c
```bash
gcc -o c/bench-zeromq c/bench-zeromq.c -lczmq
./c/bench-zeromq
BenchmarkZeroMQ-C:   76280   7628 loops/s   131095 ns/op
```

## ZeroMQ by zig
```bash
zig build -Drelease-fast=true
TCP_LIB=ZeroMQ ./zig-cache/bin/bench-tcp
BenchmarkZeroMQ-Zig:   48232   4823 loops/s   207331 ns/op
```

## nng by c
```bash
gcc c/bench-nng.c -o c/bench-nng -lnng -pthread
./c/bench-nng server tcp://127.0.0.1:5560 & server=$! && sleep 1 # run server
./c/bench-nng
BenchmarkNNG-C:   116917   11691 loops/s   85530 ns/op

kill $server # stop server
```

## nng by zig
```bash
zig build -Drelease-fast=true
TCP_LIB=nng ./zig-cache/bin/bench-tcp
```
