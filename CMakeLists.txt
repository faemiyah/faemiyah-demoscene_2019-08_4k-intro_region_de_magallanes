cmake_minimum_required(VERSION 3.1)
set(CMAKE_CONFIGURATION_TYPES "Debug;Release")
project(region_de_magallanes)

enable_language(C)
enable_language(CXX)

include("defaults.cmake")

find_boost("filesystem" "program_options" "system" "wave")
find_glew()
find_opengl()
find_png()
find_sdl2()

output_flags("DEBUG" on)

add_definitions(-DUSE_LD)

include_directories("${PROJECT_SOURCE_DIR}/src")

add_executable(region_de_magallanes
  "src/bsd_rand.c"
  "src/bsd_rand.h"
  "src/glsl_program.cpp"
  "src/glsl_program.hpp"
  "src/glsl_shader.cpp"
  "src/glsl_shader.hpp"
  "src/glsl_wave.cpp"
  "src/glsl_wave.hpp"
  "src/image_png.cpp"
  "src/image_png.hpp"
  "src/intro.cpp")
if(MSVC)
  target_link_libraries(region_de_magallanes "Imm32")
  target_link_libraries(region_de_magallanes "Version")
  target_link_libraries(region_de_magallanes "WINMM")
  target_link_libraries(region_de_magallanes "${OPENGL_gl_LIBRARY}")
  target_link_libraries(region_de_magallanes debug "${GLEW_LIBRARY_DEBUG}" optimized "${GLEW_LIBRARY}")
  target_link_libraries(region_de_magallanes debug "${PNG_LIBRARY_DEBUG}" optimized "${PNG_LIBRARY}")
  target_link_libraries(region_de_magallanes debug "${SDL2_LIBRARY_DEBUG}" optimized "${SDL2_LIBRARY}")
  target_link_libraries(region_de_magallanes debug "${ZLIB_LIBRARY_DEBUG}" optimized "${ZLIB_LIBRARY}")
else()
  target_link_libraries(region_de_magallanes "${BOOST_FILESYSTEM_LIBRARY}")
  target_link_libraries(region_de_magallanes "${BOOST_PROGRAM_OPTIONS_LIBRARY}")
  target_link_libraries(region_de_magallanes "${BOOST_SYSTEM_LIBRARY}")
  target_link_libraries(region_de_magallanes "${BOOST_THREAD_LIBRARY}")
  target_link_libraries(region_de_magallanes "${BOOST_WAVE_LIBRARY}")
  target_link_libraries(region_de_magallanes "${GLEW_LIBRARY}")
  target_link_libraries(region_de_magallanes "${PNG_LIBRARY}")
  target_link_libraries(region_de_magallanes "${SDL2_LIBRARY}")
endif()
target_link_libraries(region_de_magallanes "${THREADS_LIBRARY}")
