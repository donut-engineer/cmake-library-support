cmake_minimum_required(VERSION 3.15)
project(test-config-template LANGUAGES NONE)

list(APPEND CMAKE_MODULE_PATH "${MODULES_DIR}")
set(CMAKE_LIBRARY_SUPPORT_DIR "${MODULES_DIR}" CACHE INTERNAL "" FORCE)
include(config-template)

# ---------------------------------------------------------------------------
# Helper: read generated file and assert a string is (or is not) present
# ---------------------------------------------------------------------------
function(_assert_contains file_path pattern)
  file(READ "${file_path}" _content)
  if(NOT _content MATCHES "${pattern}")
    message(FATAL_ERROR "Expected pattern not found in ${file_path}:\n  ${pattern}")
  endif()
endfunction()

function(_assert_not_contains file_path pattern)
  file(READ "${file_path}" _content)
  if(_content MATCHES "${pattern}")
    message(FATAL_ERROR "Unexpected pattern found in ${file_path}:\n  ${pattern}")
  endif()
endfunction()

# ---------------------------------------------------------------------------
# Test: no target flags → all three included (backward compatibility)
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Test: STATIC only
# ---------------------------------------------------------------------------
generate_config_template(PACKAGE_NAME "pkg-static" STATIC)
set(_out "${PROJECT_BINARY_DIR}/cmake/pkg-static-config.cmake.in")
_assert_contains("${_out}" "pkg-static-static-targets\\.cmake")
_assert_not_contains("${_out}" "pkg-static-shared-targets\\.cmake")
_assert_not_contains("${_out}" "pkg-static-interface-targets\\.cmake")

# ---------------------------------------------------------------------------
# Test: SHARED only
# ---------------------------------------------------------------------------
generate_config_template(PACKAGE_NAME "pkg-shared" SHARED)
set(_out "${PROJECT_BINARY_DIR}/cmake/pkg-shared-config.cmake.in")
_assert_not_contains("${_out}" "pkg-shared-static-targets\\.cmake")
_assert_contains("${_out}" "pkg-shared-shared-targets\\.cmake")
_assert_not_contains("${_out}" "pkg-shared-interface-targets\\.cmake")

# ---------------------------------------------------------------------------
# Test: INTERFACE only
# ---------------------------------------------------------------------------
generate_config_template(PACKAGE_NAME "pkg-interface" INTERFACE)
set(_out "${PROJECT_BINARY_DIR}/cmake/pkg-interface-config.cmake.in")
_assert_not_contains("${_out}" "pkg-interface-static-targets\\.cmake")
_assert_not_contains("${_out}" "pkg-interface-shared-targets\\.cmake")
_assert_contains("${_out}" "pkg-interface-interface-targets\\.cmake")

# ---------------------------------------------------------------------------
# Test: STATIC and SHARED (no INTERFACE)
# ---------------------------------------------------------------------------
generate_config_template(PACKAGE_NAME "pkg-static-shared" STATIC SHARED)
set(_out "${PROJECT_BINARY_DIR}/cmake/pkg-static-shared-config.cmake.in")
_assert_contains("${_out}" "pkg-static-shared-static-targets\\.cmake")
_assert_contains("${_out}" "pkg-static-shared-shared-targets\\.cmake")
_assert_not_contains("${_out}" "pkg-static-shared-interface-targets\\.cmake")

# ---------------------------------------------------------------------------
# Test: all three explicit flags match the default (no-flag) output
# ---------------------------------------------------------------------------
generate_config_template(PACKAGE_NAME "pkg-all-explicit" STATIC SHARED INTERFACE)
set(_out "${PROJECT_BINARY_DIR}/cmake/pkg-all-explicit-config.cmake.in")
_assert_contains("${_out}" "pkg-all-explicit-static-targets\\.cmake")
_assert_contains("${_out}" "pkg-all-explicit-shared-targets\\.cmake")
_assert_contains("${_out}" "pkg-all-explicit-interface-targets\\.cmake")
