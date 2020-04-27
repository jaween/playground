cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
project(image_library VERSION 1.0.0 LANGUAGES CXX)
add_library(image_library SHARED image.cpp)
add_executable(image_test image.cpp)

set_target_properties(image_library PROPERTIES
  PUBLIC_HEADER image.h
  VERSION ${PROJECT_VERSION}
  SOVERSION 1
  OUTPUT_NAME "image"
  XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex Identity ID Goes Here"
)