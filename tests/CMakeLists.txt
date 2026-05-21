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
_add_cmake_configure_test(config-template
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-config-template")

_add_cmake_configure_test(install-rules
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-install-rules")

_add_cmake_configure_test(package-rules
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-package-rules")

# github-release-dependency: offline arg-validation tests
# Each sub-test configures the same project with a different -D flag.
# WILL_FAIL means CTest expects a non-zero exit code (cmake FATAL_ERROR).
add_test(
  NAME github-release-dependency-missing-args
  COMMAND ${CMAKE_COMMAND}
    -S "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-github-release-dependency"
    -B "${CMAKE_BINARY_DIR}/github-release-dependency-missing-args-build"
    "-DMODULES_DIR=${MODULES_DIR}"
    -DTEST_MISSING_ARGS=ON
)
set_tests_properties(github-release-dependency-missing-args PROPERTIES
  TIMEOUT   30
  LABELS    cmake-only
  WILL_FAIL TRUE)

add_test(
  NAME github-release-dependency-missing-token
  COMMAND ${CMAKE_COMMAND}
    -S "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-github-release-dependency"
    -B "${CMAKE_BINARY_DIR}/github-release-dependency-missing-token-build"
    "-DMODULES_DIR=${MODULES_DIR}"
    -DTEST_MISSING_TOKEN=ON
)
set_tests_properties(github-release-dependency-missing-token PROPERTIES
  TIMEOUT   30
  LABELS    cmake-only
  WILL_FAIL TRUE)

# ---------------------------------------------------------------------------
# sanitizers tests (one CMakeLists, one TEST_CASE per add_test)
# ---------------------------------------------------------------------------
function(_add_sanitizers_case case)
  cmake_parse_arguments(SC "WILL_FAIL" "COMPILER_ID" "" ${ARGN})
  set(_args
    -S "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-sanitizers"
    -B "${CMAKE_BINARY_DIR}/sanitizers-${case}-build"
    "-DMODULES_DIR=${MODULES_DIR}"
    "-DTEST_CASE=${case}")
  if(SC_COMPILER_ID)
    list(APPEND _args "-DSIMULATED_COMPILER_ID=${SC_COMPILER_ID}")
  endif()
  add_test(NAME sanitizers-${case} COMMAND ${CMAKE_COMMAND} ${_args})
  set_tests_properties(sanitizers-${case} PROPERTIES TIMEOUT 30 LABELS cmake-only)
  if(SC_WILL_FAIL)
    set_tests_properties(sanitizers-${case} PROPERTIES WILL_FAIL TRUE)
  endif()
endfunction()

_add_sanitizers_case(missing-target        WILL_FAIL)
_add_sanitizers_case(missing-sanitizer     WILL_FAIL)
_add_sanitizers_case(gnu-address-undefined     COMPILER_ID GNU)
_add_sanitizers_case(clang-address-undefined   COMPILER_ID Clang)
_add_sanitizers_case(gnu-rejects-memory        COMPILER_ID GNU         WILL_FAIL)
_add_sanitizers_case(appleclang-rejects-memory COMPILER_ID AppleClang  WILL_FAIL)
_add_sanitizers_case(msvc-address              COMPILER_ID MSVC)
_add_sanitizers_case(msvc-rejects-undefined    COMPILER_ID MSVC        WILL_FAIL)
_add_sanitizers_case(msvc-rejects-thread       COMPILER_ID MSVC        WILL_FAIL)
_add_sanitizers_case(msvc-rejects-memory       COMPILER_ID MSVC        WILL_FAIL)
_add_sanitizers_case(msvc-rejects-leak         COMPILER_ID MSVC        WILL_FAIL)
_add_sanitizers_case(incompat-address-thread   COMPILER_ID GNU         WILL_FAIL)
_add_sanitizers_case(incompat-address-memory   COMPILER_ID Clang       WILL_FAIL)
_add_sanitizers_case(incompat-thread-memory    COMPILER_ID Clang       WILL_FAIL)
_add_sanitizers_case(unknown-compiler          COMPILER_ID Intel       WILL_FAIL)

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

add_test(
  NAME integration-install
  COMMAND ${CMAKE_COMMAND} --install "${CMAKE_BINARY_DIR}/mylib-build"
    --prefix "${CMAKE_BINARY_DIR}/mylib-install"
)
add_test(
  NAME integration-verify
  COMMAND ${CMAKE_COMMAND}
    "-DINSTALL_PREFIX=${CMAKE_BINARY_DIR}/mylib-install"
    -P "${CMAKE_CURRENT_SOURCE_DIR}/verify-install.cmake"
)

set_tests_properties(integration-install PROPERTIES
  FIXTURES_REQUIRED mylib_built
  FIXTURES_SETUP    mylib_installed
  TIMEOUT           60
  LABELS            integration)
set_tests_properties(integration-verify PROPERTIES
  FIXTURES_REQUIRED mylib_installed
  TIMEOUT           30
  LABELS            integration)
