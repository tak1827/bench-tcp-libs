#include <stdio.h>
#include <time.h>
#include <czmq.h>

zsock_t *push;
zsock_t *pull;

int bench(const unsigned char *name, double benchtime) {
  clock_t start_t = clock();

  int loops = 0;
  while (clock() < start_t + benchtime) {
    zstr_send (push, "HelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHello");
    char *string = zstr_recv (pull);
    // puts(string);
    zstr_free (&string);
    loops += 1;
  }

  int loop_per_s = loops * CLOCKS_PER_SEC / benchtime;
  int time_per_op = benchtime / loops * 1000;
  printf("%s:   %d   %d loops/s   %d ns/op\n", name, loops, loop_per_s, time_per_op);
  return 0;
}

int main (void) {
  push = zsock_new_push ("@tcp://127.0.0.1:5560");
  pull = zsock_new_pull (">tcp://127.0.0.1:5560");

  double benchtime = 10 * CLOCKS_PER_SEC; // 10s
  // double benchtime = CLOCKS_PER_SEC; // 1s
  if (bench("BenchmarkZeroMQ-C", benchtime) > 0) {
    return 1;
  }

  zsock_destroy (&pull);
  zsock_destroy (&push);
  return 0;
}
