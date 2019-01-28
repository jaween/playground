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
const float noise_amplitude = 0.2;

float signed_distance(const Vec3f& p) {
  Vec3f s = Vec3f(p).normalize(sphere_radius);
  float displacement = sin(16 * s.x) * sin(16 * s.y) * sin(16 * s.z) * noise_amplitude;
  return p.norm() - (sphere_radius + displacement);
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

Vec3f distance_field_normal(const Vec3f& pos) {
  const float eps = 0.1f;
  float d = signed_distance(pos);
  float nx = signed_distance(pos + Vec3f(eps, 0, 0)) - d;
  float ny = signed_distance(pos + Vec3f(0, eps, 0)) - d;
  float nz = signed_distance(pos + Vec3f(0, 0, eps)) - d;
  return Vec3f(nx, ny, nz).normalize();
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
        Vec3f light_dir = (Vec3f(10, 10, 10) - hit).normalize();
        float light_intensity = std::max(0.4f, light_dir * distance_field_normal(hit));
        framebuffer[i + j * width] = Vec3f(1, 1, 1) * light_intensity;
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
      ofs << (char)(std::max(0, std::min(255, static_cast<int>(255 * framebuffer[i][j]))));
    }
  }
  ofs.close();
  
  return 0;
}

