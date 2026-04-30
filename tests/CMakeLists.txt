cmake_minimum_required(VERSION 3.14)
project(cmake-library-support-tests NONE)
include(CTest)

# MODULES_DIR can be passed from CI or defaults to the sibling cmake/ directory
if(NOT MODULES_DIR)
  get_filename_component(MODULES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../cmake" ABSOLUTE)
endif()

# ---------------------------------------------------------------------------
# Helper: register a cmake-configure test (fails if cmake exits non-zero)
# ---------------------------------------------------------------------------
function(_add_cmake_configure_test name source_dir)
  add_test(
    NAME ${name}
    COMMAND ${CMAKE_COMMAND}
      -S "${source_dir}"
      -B "${CMAKE_BINARY_DIR}/${name}-build"
      "-DMODULES_DIR=${MODULES_DIR}"
      ${ARGN}
  )
  set_tests_properties(${name} PROPERTIES TIMEOUT 60 LABELS cmake-only)
endfunction()

# ---------------------------------------------------------------------------
# Pure-CMake tests (no compiler required)
# ---------------------------------------------------------------------------
_add_cmake_configure_test(cmake-library-support
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-cmake-library-support")

_add_cmake_configure_test(find-modules
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-find-modules")

_add_cmake_configure_test(config-template
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-config-template")

# generate-version is a cmake -P script; invoke via a wrapper script
add_test(
  NAME generate-version
  COMMAND ${CMAKE_COMMAND}
    "-DMODULES_DIR=${MODULES_DIR}"
    "-DSOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}/.."
    "-DBINARY_DIR=${CMAKE_BINARY_DIR}/gen-version-build"
    "-DTEST_DIR=${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-generate-version"
    -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-generate-version/run_test.cmake"
)
set_tests_properties(generate-version PROPERTIES TIMEOUT 30 LABELS cmake-only)
