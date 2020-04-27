#include <stdio.h>

#include "hello.h"

int main() {
    hello_world();
}

void hello_world() {
  printf("C: Hello from C!\n");
  printf("C: My address is %p\n", hello_world);
}
