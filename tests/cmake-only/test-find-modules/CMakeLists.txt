cmake_minimum_required(VERSION 3.14)
project(test-find-modules NONE)

list(APPEND CMAKE_MODULE_PATH "${MODULES_DIR}")
include(cmake-library-support)
include(find-modules)

# Exercise generate_find_module with a header (full path)
generate_find_module(
  MODULE_NAME  TestLib
  NAMESPACE    TestLib
  TARGET_NAME  testlib
  HEADER_NAME  "testlib/testlib.hpp"
  PACKAGE_DOC  "test-lib"
)

set(_out "${PROJECT_BINARY_DIR}/cmake/FindTestLib.cmake")
if(NOT EXISTS "${_out}")
  message(FATAL_ERROR "FindTestLib.cmake was not generated at: ${_out}")
endif()

file(READ "${_out}" _content)

foreach(_pattern
  "find_path\\(TestLib_INCLUDE_DIR"
  "find_library\\(TestLib_SHARED_LIBRARY"
  "find_library\\(TestLib_STATIC_LIBRARY"
  "TestLib::testlib_SHARED"
  "TestLib::testlib_STATIC"
  "find_package_handle_standard_args\\(TestLib"
)
  if(NOT _content MATCHES "${_pattern}")
    message(FATAL_ERROR "Expected pattern not found in FindTestLib.cmake: ${_pattern}")
  endif()
endforeach()

# Exercise generate_find_module without HEADER_NAME (optional argument)
generate_find_module(
  MODULE_NAME  NoHeaderLib
  NAMESPACE    NoHeaderLib
  TARGET_NAME  noheaderlib
  PACKAGE_DOC  "no-header-lib"
)

set(_out2 "${PROJECT_BINARY_DIR}/cmake/FindNoHeaderLib.cmake")
if(NOT EXISTS "${_out2}")
  message(FATAL_ERROR "FindNoHeaderLib.cmake was not generated at: ${_out2}")
endif()

file(READ "${_out2}" _content2)

# Without HEADER_NAME, find_path should not appear
if(_content2 MATCHES "find_path\\(")
  message(FATAL_ERROR "find_path should not appear in FindNoHeaderLib.cmake when HEADER_NAME is omitted")
endif()

foreach(_pattern
  "find_library\\(NoHeaderLib_SHARED_LIBRARY"
  "find_library\\(NoHeaderLib_STATIC_LIBRARY"
)
  if(NOT _content2 MATCHES "${_pattern}")
    message(FATAL_ERROR "Expected pattern not found in FindNoHeaderLib.cmake: ${_pattern}")
  endif()
endforeach()
