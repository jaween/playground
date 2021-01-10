#include <cstdio>
#include <cstdlib>

#include "include/dart_api_dl.h"

extern "C" void init_dart_dynamic_linking(void* data) {
  if (Dart_InitializeApiDL(data) != 0) {
    printf("Failed to initialise Dart VM API\n");
  }
}

static void run_finaliser(void* isolate_callback_data, void* peer) {
  printf("Finalising: %p\n", peer);
  free(peer);
}

extern "C" uint32_t* register_finaliser(Dart_Handle handle, intptr_t length) {
  uint32_t* native_data = new uint32_t[length]();

  auto weak_handle = Dart_NewFinalizableHandle_DL(
    handle, reinterpret_cast<void*>(native_data), length, run_finaliser);
    printf("Registered finaliser: %p\n", native_data);
  return native_data;
}