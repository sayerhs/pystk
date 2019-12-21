
cmake_minimum_required(VERSION 3.12.0)

project(pystk CXX C)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})
include(${CMAKE_SOURCE_DIR}/cmake/PyStkUtils.cmake)

find_package(PythonExtensions REQUIRED)
find_package(Cython REQUIRED)
find_package(NumPy REQUIRED)
find_package(MPI REQUIRED)
find_package(STK REQUIRED)

add_subdirectory(stk)
