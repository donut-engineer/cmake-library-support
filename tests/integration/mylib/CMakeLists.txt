cmake_minimum_required(VERSION 3.14)
project(mylib VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

enable_testing()

if(NOT MODULES_DIR)
  get_filename_component(MODULES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../cmake" ABSOLUTE)
endif()

list(APPEND CMAKE_MODULE_PATH "${MODULES_DIR}")
include(cmake-library-support)
include(config-template)
include(install-rules)

# Three library targets required by library_install_rules
add_library(mylib        STATIC src/mylib.cpp)
add_library(mylibShared  SHARED src/mylib.cpp)
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
