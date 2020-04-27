#include <stdint.h>
#include <stdio.h>

#include "image.h"

int main() {
    
}

extern "C" {
  void image_modification(uint32_t* image, uint16_t width, uint16_t height) {
    uint32_t size = width * height;
    printf("C: Writing to image of size %dx%d\n", width, height);
    for (uint32_t i = 0; i < size; i++) {
      image[i] = 0xFF00CC00;
    }
  }
}
