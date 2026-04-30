cmake_minimum_required(VERSION 3.14)
project(test-config-template LANGUAGES NONE)

list(APPEND CMAKE_MODULE_PATH "${MODULES_DIR}")
include(cmake-library-support)
include(config-template)

generate_config_template(PACKAGE_NAME "my-library")

set(_out "${PROJECT_BINARY_DIR}/cmake/my-library-config.cmake.in")
if(NOT EXISTS "${_out}")
  message(FATAL_ERROR "my-library-config.cmake.in was not generated at: ${_out}")
endif()

file(READ "${_out}" _content)
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/expected-my-library-config.cmake.in" _expected)
if(NOT _content STREQUAL _expected)
  message(FATAL_ERROR "Generated my-library-config.cmake.in does not match expected content")
endif()
