#include <chrono>
#include <iostream>
#include <thread>

#include "include/dart_api_dl.h"

extern "C" void init_dart_dynamic_linking(void* data) {
  if (Dart_InitializeApiDL(data) != 0) {
    std::cerr << "Failed to initialise Dart VM API\n" << std::endl;
  }
}

static void finalizer(
    void* isolate_callback_data,
    Dart_WeakPersistentHandle handle,
    void* peer) {
  auto data = reinterpret_cast<uint8_t*>(peer);
  std::clog << "Finalising " << peer << std::endl;
  delete [] data;
}

void example(int64_t port) {
  // Send values
  for (auto i = 1; i <= 3; i++) {
    std::this_thread::sleep_for (std::chrono::seconds(1));
    Dart_CObject obj;
    obj.type = Dart_CObject_kInt64;
    obj.value.as_int64 = 1;
    auto result = Dart_PostCObject_DL(port, &obj);
    std::clog << "C Message sent with result " << result << std::endl;
  }

  // Send array (not copied to Dart, ownership lives in C++)
  long int length = 10;
  auto data = new uint8_t[length];
  for (auto i = 0; i < length; i++) {
    data[i] = i;
  }
  Dart_CObject obj;
  obj.type = Dart_CObject_kExternalTypedData;
  obj.value.as_external_typed_data.type = Dart_TypedData_kUint8;
  obj.value.as_external_typed_data.length = length;
  obj.value.as_external_typed_data.data = data;
  obj.value.as_external_typed_data.peer = reinterpret_cast<void*>(data);
  obj.value.as_external_typed_data.callback = finalizer;
  auto result = Dart_PostCObject_DL(port, &obj);
  if (!result) {
    std::clog << "Result was " << result << std::endl;
  }

  std::clog << "C Thread complete" << std::endl;
}

extern "C" void execute_work(int64_t port) {
  std::thread t1(example, port);
  t1.detach();
  std::clog << "C Thread detached" << std::endl;
}

