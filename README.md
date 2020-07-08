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
```