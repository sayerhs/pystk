
cmake_minimum_required(VERSION 3.12.0)

project(pystk CXX C)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})
include(${CMAKE_SOURCE_DIR}/cmake/PyStkUtils.cmake)

option(ENABLE_RPATH "Enable RPATH options for linking" ON)

find_package(PythonExtensions REQUIRED)
find_package(Cython REQUIRED)
find_package(NumPy REQUIRED)
find_package(MPI REQUIRED)
find_package(STK REQUIRED)

if (ENABLE_RPATH)
  set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
  set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
  set(CMAKE_SKIP_BUILD_RPATH FALSE)
  set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
endif(ENABLE_RPATH)

add_subdirectory(stk)
