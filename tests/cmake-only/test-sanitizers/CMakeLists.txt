cmake_minimum_required(VERSION 3.15)
project(test-sanitizers LANGUAGES NONE)

list(APPEND CMAKE_MODULE_PATH "${MODULES_DIR}")
set(CMAKE_LIBRARY_SUPPORT_DIR "${MODULES_DIR}" CACHE INTERNAL "" FORCE)

# Test-only override: force the compiler ID the module sees. Real consumers get
# this from project(); this driver uses LANGUAGES NONE so no compiler is invoked,
# and we set the id by hand to exercise per-compiler branches without a toolchain.
# By default the value is the C++ id; with SIMULATED_C it is set as the C id
# instead (leaving the C++ id empty) to exercise the C-only fallback.
if(SIMULATED_COMPILER_ID)
  if(SIMULATED_C)
    set(CMAKE_C_COMPILER_ID "${SIMULATED_COMPILER_ID}")
  else()
    set(CMAKE_CXX_COMPILER_ID "${SIMULATED_COMPILER_ID}")
  endif()
endif()

include(sanitizers)

add_library(dummy INTERFACE)

function(_assert_in_list list_var needle)
  if(NOT "${needle}" IN_LIST ${list_var})
    message(FATAL_ERROR "Expected '${needle}' in ${list_var}; got: ${${list_var}}")
  endif()
endfunction()

if(TEST_CASE STREQUAL "missing-target")
  target_enable_sanitizers(ADDRESS)
elseif(TEST_CASE STREQUAL "missing-sanitizer")
  target_enable_sanitizers(TARGET dummy)
elseif(TEST_CASE STREQUAL "gnu-address-undefined" OR
       TEST_CASE STREQUAL "clang-address-undefined" OR
       TEST_CASE STREQUAL "c-gnu-address-undefined" OR
       TEST_CASE STREQUAL "c-clang-address-undefined")
  target_enable_sanitizers(TARGET dummy ADDRESS UNDEFINED)
  get_target_property(_co dummy INTERFACE_COMPILE_OPTIONS)
  get_target_property(_lo dummy INTERFACE_LINK_OPTIONS)
  _assert_in_list(_co "-fsanitize=address,undefined")
  _assert_in_list(_co "-fno-omit-frame-pointer")
  _assert_in_list(_lo "-fsanitize=address,undefined")
elseif(TEST_CASE STREQUAL "gnu-rejects-memory" OR
       TEST_CASE STREQUAL "appleclang-rejects-memory")
  target_enable_sanitizers(TARGET dummy MEMORY)
elseif(TEST_CASE STREQUAL "msvc-address")
  target_enable_sanitizers(TARGET dummy ADDRESS)
  get_target_property(_co dummy INTERFACE_COMPILE_OPTIONS)
  get_target_property(_lo dummy INTERFACE_LINK_OPTIONS)
  _assert_in_list(_co "/fsanitize=address")
  if(NOT _lo STREQUAL "_lo-NOTFOUND" AND NOT _lo STREQUAL "")
    message(FATAL_ERROR "Expected no INTERFACE_LINK_OPTIONS for MSVC; got: ${_lo}")
  endif()
elseif(TEST_CASE STREQUAL "msvc-rejects-undefined")
  target_enable_sanitizers(TARGET dummy UNDEFINED)
elseif(TEST_CASE STREQUAL "msvc-rejects-thread")
  target_enable_sanitizers(TARGET dummy THREAD)
elseif(TEST_CASE STREQUAL "msvc-rejects-memory")
  target_enable_sanitizers(TARGET dummy MEMORY)
elseif(TEST_CASE STREQUAL "msvc-rejects-leak")
  target_enable_sanitizers(TARGET dummy LEAK)
elseif(TEST_CASE STREQUAL "incompat-address-thread")
  target_enable_sanitizers(TARGET dummy ADDRESS THREAD)
elseif(TEST_CASE STREQUAL "incompat-address-memory")
  target_enable_sanitizers(TARGET dummy ADDRESS MEMORY)
elseif(TEST_CASE STREQUAL "incompat-thread-memory")
  target_enable_sanitizers(TARGET dummy THREAD MEMORY)
elseif(TEST_CASE STREQUAL "unknown-compiler")
  target_enable_sanitizers(TARGET dummy ADDRESS)
else()
  message(FATAL_ERROR "test-sanitizers: unknown TEST_CASE '${TEST_CASE}'")
endif()
