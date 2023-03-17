cmake_minimum_required (VERSION 3.23)
project (iwasmcr LANGUAGES C CXX)

# --------------------
# CMake Configuration
# --------------------

set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_VERBOSE_MAKEFILE OFF)
if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif ()

# --------------------
# Compiler Configuration
# --------------------

set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wformat -Wformat-security -Wshadow")
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wformat -Wformat-security -Wno-unused")
# Reset default linker flags
set (CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")
set (CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "")
set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--gc-sections")

# --------------------
# WAMR Configuration
# --------------------

set(WAMR_BUILD_PLATFORM "linux")
set(WAMR_BUILD_TARGET "X86_64")
set(WAMR_BUILD_INTERP 1)
set(WAMR_BUILD_AOT 1)
set(WAMR_BUILD_JIT 0)
set(WAMR_BUILD_FAST_JIT 0)
set(WAMR_BUILD_LIBC_BUILTIN 1)
set(WAMR_BUILD_LIBC_WASI 1)
set(WAMR_BUILD_FAST_INTERP 0)
set(WAMR_BUILD_MULTI_MODULE 0)
set(WAMR_BUILD_LIB_PTHREAD 0)
set(WAMR_BUILD_LIB_WASI_THREADS 0)
set(WAMR_BUILD_MINI_LOADER 0)
set(WAMR_BUILD_SIMD 0)
set(WAMR_BUILD_REF_TYPES 0)
set(WAMR_BUILD_DEBUG_INTERP 1)

# --------------------
# WAMR Library
# --------------------

set (WAMR_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../..)
include (${WAMR_ROOT_DIR}/build-scripts/runtime_lib.cmake)
add_library(vmlib ${WAMR_RUNTIME_LIB_SOURCE})
target_compile_options(vmlib PRIVATE -Wno-unused-command-line-argument)

# --------------------
# Dependencies
# --------------------

# find_package(Boost REQUIRED)
# find_package(protobuf REQUIRED)
#
# if (Boost_FOUND)
#     message(STATUS "hello: ${BOOST_INCLUDE_DIRS}")
#     message(STATUS "hello: ${Boost_INCLUDE_DIRS}")
#     message(STATUS "hello: ${Boost_LIBRARIES}")
# endif()

# --------------------
# C/R Library
# --------------------

add_subdirectory(cr-lib)

# --------------------
# iwasm-cr binary
# --------------------

message(STATUS "Include paths: ${CMAKE_INCLUDE_PATH}")

include(${SHARED_DIR}/utils/uncommon/shared_uncommon.cmake)
add_executable(iwasm-cr main.cpp ${UNCOMMON_SHARED_SOURCE})
set_target_properties(iwasm-cr PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_include_directories(iwasm-cr PUBLIC ${Boost_INCLUDE_DIRS})
target_link_libraries(iwasm-cr
    vmlib
    cr-lib
    ${LLVM_AVAILABLE_LIBS}
    ${UV_A_LIBS}
    m
    dl
    pthread
    boost_program_options
)
