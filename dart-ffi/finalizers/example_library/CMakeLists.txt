cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
project(rasterization_library VERSION 1.0.0 LANGUAGES C)
add_library(rasterization_library SHARED rasterize.c)
add_executable(rasterization rasterize.c)

# Compiler flags
if (MSVC)
    add_compile_options(/W4 /WX)
else()
    add_compile_options(-Wall -Wextra -pedantic -Werror)
endif()

set_target_properties(rasterization_library PROPERTIES
  PUBLIC_HEADER rasterize.h
  VERSION ${PROJECT_VERSION}
  SOVERSION 1
  OUTPUT_NAME "rasterization"
  XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex Identity ID Goes Here"
)