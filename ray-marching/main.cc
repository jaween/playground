// Based on https://github.com/ssloy/tinykaboom/wiki

#define _USE_MATH_DEFINES_
#include <cmath>
#include <algorithm>
#include <limits>
#include <iostream>
#include <fstream>
#include <vector>
#include "geometry.h"

const float sphere_radius = 1.5;

float signed_distance(const Vec3f& p) {
  return p.norm() - sphere_radius;
}

bool sphere_trace(const Vec3f& orig, const Vec3f& dir, Vec3f& pos) {
  pos = orig;
  for (size_t i = 0; i < 128; i++){
    float d = signed_distance(pos);
    if (d < 0) {
      return true;
    }
    pos = pos + dir * std::max(d * 0.1f, 0.01f);
  }
  return false;
}

int main() {
  const int width = 640;
  const int height = 480;
  const float fov = M_PI/3.0f;
  std::vector<Vec3f> framebuffer(width * height);
  
#pragma omp parallel for
  // Rendering loop
  for (size_t j = 0; j < height; j++) {
    for (size_t i = 0; i < width; i++) {
      float dir_x = (i + 0.5) - width / 2.0f;
      float dir_y = -(j + 0.5) + height / 2.0f;
      float dir_z = -height / (2.0f * tan(fov/2.0f));

      Vec3f hit;
      if (sphere_trace(Vec3f(0, 0, 3), Vec3f(dir_x, dir_y, dir_z).normalize(), hit)) {
        framebuffer[i + j * width] = Vec3f(1, 1, 1);
      } else {
        framebuffer[i + j * width] = Vec3f(0.2, 0.7, 0.8);
      }
    }
  }

  // Save file
  std::ofstream ofs("./out.ppm", std::ios::binary);
  ofs << "P6\n" << width << " " << height << "\n255\n";
  for (size_t i = 0; i < height * width; i++) {
    for (size_t j = 0; j < 3; j++) {
      ofs << (char)(255 * std::max(0, std::min(255, static_cast<int>(255 * framebuffer[i][j]))));
    }
  }
  ofs.close();
  
  return 0;
}

