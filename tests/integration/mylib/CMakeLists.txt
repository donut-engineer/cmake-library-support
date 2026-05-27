cmake_minimum_required(VERSION 3.15)

# The library source (src/mylib.c) is plain C, valid as both C and C++. The test
# suite configures this one consumer twice: as a C++ project (CONSUMER_LANG=CXX,
# GoogleTest driver) and as a C project (CONSUMER_LANG=C, plain-C driver), so the
# modules are exercised for both languages without duplicating the library.
if(NOT CONSUMER_LANG)
  set(CONSUMER_LANG CXX)
endif()

project(mylib VERSION 1.0.0 LANGUAGES ${CONSUMER_LANG})

if(CONSUMER_LANG STREQUAL "CXX")
  set(CMAKE_CXX_STANDARD 17)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  # Compile the .c source with the C++ compiler so this build is pure C++ and
  # the modules see CMAKE_CXX_COMPILER_ID (the C++ code path).
  set_source_files_properties(src/mylib.c PROPERTIES LANGUAGE CXX)
else()
  set(CMAKE_C_STANDARD 11)
  set(CMAKE_C_STANDARD_REQUIRED ON)
endif()

enable_testing()

if(NOT MODULES_DIR)
  get_filename_component(MODULES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../cmake" ABSOLUTE)
endif()

list(APPEND CMAKE_MODULE_PATH "${MODULES_DIR}")
set(CMAKE_LIBRARY_SUPPORT_DIR "${MODULES_DIR}" CACHE INTERNAL "" FORCE)
include(config-template)
include(install-rules)

# Three library targets required by library_install_rules
add_library(mylib        STATIC src/mylib.c)
add_library(mylibShared  SHARED src/mylib.c)
add_library(mylibIface   INTERFACE)

foreach(_t mylib mylibShared)
  target_include_directories(${_t} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>)
endforeach()
target_include_directories(mylibIface INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>)

# config-template must run before install-rules (it creates the .cmake.in file)
generate_config_template(PACKAGE_NAME "mylib")

# Exercise install-rules.cmake (registers install rules, calls configure_package_config_file)
library_install_rules(
  PACKAGE_NAME     mylib
  NAMESPACE        mylib
  STATIC_TARGET    mylib
  SHARED_TARGET    mylibShared
  INTERFACE_TARGET mylibIface
)

add_subdirectory(test)
