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
const float noise_amplitude = 1.0;

template <typename T> inline T lerp(const T& v0, const T& v1, float t) {
  return v0 + (v1 - v0) * std::max(0.0f, std::min(1.0f, t));
}

float hash(const float n) {
  float x = sin(n) * 43758.5453f;
  return x - floor(x);
}

float noise(const Vec3f &x) {
  Vec3f p(floor(x.x), floor(x.y), floor(x.z));
  Vec3f f(x.x - p.x, x.y - p.y, x.z - p.z);
  f = f * (f * (Vec3f(3.0f, 3.0f, 3.0f) - f * 2.0f));
  float n = p * Vec3f(1.0f, 57.0f, 113.0f);
  return lerp(lerp(lerp(hash(n + 0.0f), hash(n + 1.0f), f.x),
                   lerp(hash(n + 57.0f), hash(n + 58.0f), f.x), f.y),
              lerp(lerp(hash(n + 113.0f), hash(n + 114.0f), f.x),
                   lerp(hash(n + 170.f), hash(n + 171.0f), f.x), f.y), f.z);
}

Vec3f rotate(const Vec3f &v) {
  return Vec3f(Vec3f(0.0f, 0.8f, 0.6f) * v, Vec3f(-0.8f, 0.36f, -0.48f) * v, Vec3f(-0.6f, -0.48f, 0.64f) * v);
}

float fractal_brownian_motion(const Vec3f& x) {
  Vec3f p = rotate(x);
  float f = 0;
  f += 0.5f * noise(p);
  p = p * 2.32;
  f += 0.25f * noise(p);
  p = p * 3.03;
  f += 0.125f * noise(p);
  p = p * 3.03;
  f += 0.0625f * noise(p);
  return f / 0.9375;
}

Vec3f palette_fire(const float d) {
  const Vec3f yellow(1.7, 1.3, 1.0);
  const Vec3f orange(1.0, 0.6, 0.0);
  const Vec3f red(1.0, 0.0, 0.0);
  const Vec3f darkgrey(0.2, 0.2, 0.2);
  const Vec3f grey(0.4, 0.4, 0.4);
  
  float x = std::max(0.0f, std::min(1.0f, d));
  if (x < 0.25f) {
    return lerp(grey, darkgrey, x * 4.0f);
  } else if (x < 0.5f) {
    return lerp(darkgrey, red, x * 4.0f - 1.0f);
  } else if (x < 0.75f) {
    return lerp(red, orange, x * 4.0f - 2.0f);
  }
  return lerp(orange, yellow, x * 4.0f - 3.0f);
}

float signed_distance(const Vec3f& p) {
  float displacement = -fractal_brownian_motion(p * 3.4) * noise_amplitude;
  return p.norm() - (sphere_radius + displacement);
}

bool sphere_trace(const Vec3f& orig, const Vec3f& dir, Vec3f& pos) {
  if (orig * orig - pow(orig * dir, 2) > pow(sphere_radius, 2)) {
    return false;
  }

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
        float noise_level = (sphere_radius - hit.norm()) / noise_amplitude;
        Vec3f light_dir = (Vec3f(10, 10, 10) - hit).normalize();
        float light_intensity = std::max(0.4f, light_dir * distance_field_normal(hit));
        framebuffer[i + j * width] = palette_fire((-0.2f + noise_level) * 2) * light_intensity;
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

