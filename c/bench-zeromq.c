#include <stdio.h>
#include <time.h>
#include <czmq.h>

zsock_t *push;
zsock_t *pull;

int bench(const unsigned char *name, double benchtime) {
  clock_t start_t = clock();

  int loops = 0;
  while (clock() < start_t + benchtime) {
    zstr_send (push, "Hello, World");
    char *string = zstr_recv (pull);
    zstr_free (&string);
    loops += 1;
  }

  int loop_per_s = loops * CLOCKS_PER_SEC / benchtime;
  int time_per_op = benchtime / loops;
  printf("%s:   %d   %d loops/s   %d ns/op\n", name, loops, loop_per_s, time_per_op);
  return 0;
}

int main (void) {
  push = zsock_new_push ("inproc://example");
  pull = zsock_new_pull ("inproc://example");

  double benchtime = 10 * CLOCKS_PER_SEC; // 10s
  if (bench("BenchmarkZeroMQ-C", benchtime) > 0) {
    return 1;
  }

  zsock_destroy (&pull);
  zsock_destroy (&push);
  return 0;
}
