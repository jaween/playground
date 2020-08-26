#include <stdio.h>
#include <stdlib.h>

#include "include/dart_api_dl.h"
#include "include/dart_api_dl.c"
#include "example.h"

void initDartVmApi(void* data) {
  if (Dart_InitializeApiDL(data) != 0) {
    printf("Failed to initialise Dart VM API\n");
  }
}

static void RunFinalizer(
  void* isolate_callback_data,
  Dart_WeakPersistentHandle handle,
  void* peer) {
    printf("FINALIZING: %p %x %x %p\n", peer, ((uint32_t*) peer)[0], ((uint32_t*) peer)[1], isolate_callback_data);
    free(peer);
}

void registerFinaliser(Dart_Handle h, uint32_t* native_data, intptr_t length) {
  auto weak_handle = Dart_NewWeakPersistentHandle_DL(
    h, reinterpret_cast<void*>(native_data), length, RunFinalizer);
    printf("Registered finaliser: %p\n", native_data);
}