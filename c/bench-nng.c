#include <stdio.h>
#include <string.h>
#include <time.h>
#include <nng/nng.h>
#include <nng/protocol/pipeline0/pull.h>
#include <nng/protocol/pipeline0/push.h>

#define Server "server"

nng_socket client_sock;
// 1400 length
char* msg = "HelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHello";

int log_error(const char *func, int rv) {
  fprintf(stderr, "%s: %s\n", func, nng_strerror(rv));
  return 1;
}

int server(const char *url) {
  nng_socket sock;
  int rv;

  if ((rv = nng_pull0_open(&sock)) != 0) {
    return log_error("nng_pull0_open", rv);
  }
  if ((rv = nng_listen(sock, url, NULL, 0)) != 0) {
    return log_error("nng_listen", rv);
  }

  printf("listening: %s\n", url);

  for (;;) {
    char *buf = NULL;
    size_t sz;
    if ((rv = nng_recv(sock, &buf, &sz, NNG_FLAG_ALLOC)) != 0) {
      return log_error("nng_recv", rv);
    }
    // printf("server: recv \"%s\"\n", buf);
    nng_free(buf, sz);
  }

  return 0;
}

int bench(const unsigned char *name, double benchtime) {
  clock_t start_t = clock();

  int loops = 0;
  while (clock() < start_t + benchtime) {
    // printf("client: send \"%s\"\n", msg);
    if (nng_send(client_sock, msg, strlen(msg)+1, 0) != 0) {
      printf("faild to send");
      return 1;
    }
    loops += 1;
  }

  int loop_per_s = loops * CLOCKS_PER_SEC / benchtime;
  int time_per_op = benchtime / loops * 1000;
  printf("%s:   %d   %d loops/s   %d ns/op\n", name, loops, loop_per_s, time_per_op);
  return 0;
}

int clinet(const char *url) {
  int rv;

  if ((rv = nng_push0_open(&client_sock)) != 0) {
    return log_error("nng_push0_open", rv);
  }
  if ((rv = nng_dial(client_sock, url, NULL, 0)) != 0) {
    return log_error("nng_dial", rv);
  }
}

int main(int argc, char **argv) {
  // Start server
  if ((argc > 1) && (strcmp(Server, argv[1]) == 0)) {
    return (server("tcp://127.0.0.1:5560"));
  }

  // client connect to server
  if (clinet("tcp://127.0.0.1:5560") > 0) {
    return 1;
  }

  double benchtime = 10 * CLOCKS_PER_SEC; // 10s
  // double benchtime = CLOCKS_PER_SEC; // 1s
  if (bench("BenchmarkNNG-C", benchtime) > 0) {
    return 1;
  }

  nng_close(client_sock);
  return 0;
}
