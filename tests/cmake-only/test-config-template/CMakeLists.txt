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

foreach(_pattern
  "@PACKAGE_INIT@"
  "my-library-static-targets.cmake"
  "my-library-shared-targets.cmake"
  "my-library-interface-targets.cmake"
  "check_required_components\\(my-library\\)"
)
  if(NOT _content MATCHES "${_pattern}")
    message(FATAL_ERROR "Expected pattern not found in my-library-config.cmake.in: ${_pattern}")
  endif()
endforeach()
