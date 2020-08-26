#include <stdint.h>

#include "include/dart_api_dl.h"

#ifdef __cplusplus
extern "C" {
#endif

void initDartVmApi(void* data);

void registerFinaliser(Dart_Handle h, uint32_t* native_data, intptr_t length);

#ifdef __cplusplus
}
#endif