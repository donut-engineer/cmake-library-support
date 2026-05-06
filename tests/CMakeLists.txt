cmake_minimum_required(VERSION 3.15)
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

_add_cmake_configure_test(config-template
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-config-template")

_add_cmake_configure_test(install-rules
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-install-rules")

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

# ---------------------------------------------------------------------------
# Integration tests (require clang + LLVM 18)
# Four steps chained via CTest fixtures: configure → build → test → coverage
# ---------------------------------------------------------------------------
add_test(
  NAME integration-configure
  COMMAND ${CMAKE_COMMAND}
    -S "${CMAKE_CURRENT_SOURCE_DIR}/integration/mylib"
    -B "${CMAKE_BINARY_DIR}/mylib-build"
    "-DMODULES_DIR=${MODULES_DIR}"
    -DCMAKE_BUILD_TYPE=Debug
    -DCMAKE_C_COMPILER=clang
    -DCMAKE_CXX_COMPILER=clang++
)
add_test(
  NAME integration-build
  COMMAND ${CMAKE_COMMAND} --build "${CMAKE_BINARY_DIR}/mylib-build" --parallel
)
add_test(
  NAME integration-test
  COMMAND ${CMAKE_CTEST_COMMAND}
    --test-dir "${CMAKE_BINARY_DIR}/mylib-build"
    --output-on-failure
)
add_test(
  NAME integration-coverage
  COMMAND ${CMAKE_COMMAND}
    --build "${CMAKE_BINARY_DIR}/mylib-build"
    --target coverage
)

set_tests_properties(integration-configure PROPERTIES
  FIXTURES_SETUP    mylib_configured
  TIMEOUT           120
  LABELS            integration)
set_tests_properties(integration-build PROPERTIES
  FIXTURES_REQUIRED mylib_configured
  FIXTURES_SETUP    mylib_built
  TIMEOUT           300
  LABELS            integration)
set_tests_properties(integration-test PROPERTIES
  FIXTURES_REQUIRED mylib_built
  FIXTURES_SETUP    mylib_tested
  TIMEOUT           120
  LABELS            integration)
set_tests_properties(integration-coverage PROPERTIES
  FIXTURES_REQUIRED mylib_tested
  TIMEOUT           120
  LABELS            integration)
