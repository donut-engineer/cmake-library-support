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

# coverage: argument-validation and compiler-guard paths
add_test(
  NAME coverage-unknown-compiler
  COMMAND ${CMAKE_COMMAND}
    -S "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-coverage"
    -B "${CMAKE_BINARY_DIR}/coverage-unknown-compiler-build"
    "-DMODULES_DIR=${MODULES_DIR}"
    -DRUN_REPORT_TARGET=ON
    -DCMAKE_CXX_COMPILER_ID=SomeUnknown
)
set_tests_properties(coverage-unknown-compiler PROPERTIES
  TIMEOUT   30
  LABELS    cmake-only
  WILL_FAIL TRUE)

# coverage: C-only project (empty CXX id) falls back to the C compiler id and
# the compiler guard accepts it. Expected to succeed (no WILL_FAIL).
add_test(
  NAME coverage-c-fallback
  COMMAND ${CMAKE_COMMAND}
    -S "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-coverage"
    -B "${CMAKE_BINARY_DIR}/coverage-c-fallback-build"
    "-DMODULES_DIR=${MODULES_DIR}"
    -DRUN_REPORT_TARGET=ON
    -DCMAKE_C_COMPILER_ID=GNU
)
set_tests_properties(coverage-c-fallback PROPERTIES
  TIMEOUT 30
  LABELS  cmake-only)

# coverage: optional NAME argument creates a custom-named report target instead
# of the default 'coverage' target.
add_test(
  NAME coverage-custom-target-name
  COMMAND ${CMAKE_COMMAND}
    -S "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-coverage"
    -B "${CMAKE_BINARY_DIR}/coverage-custom-target-name-build"
    "-DMODULES_DIR=${MODULES_DIR}"
    -DRUN_NAMED_REPORT_TARGET=ON
    -DCMAKE_CXX_COMPILER_ID=GNU
)
set_tests_properties(coverage-custom-target-name PROPERTIES
  TIMEOUT 30
  LABELS  cmake-only)

# coverage: unknown keyword argument is rejected with a FATAL_ERROR.
add_test(
  NAME coverage-unknown-arg
  COMMAND ${CMAKE_COMMAND}
    -S "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-coverage"
    -B "${CMAKE_BINARY_DIR}/coverage-unknown-arg-build"
    "-DMODULES_DIR=${MODULES_DIR}"
    -DRUN_UNKNOWN_ARG=ON
    -DCMAKE_CXX_COMPILER_ID=GNU
)
set_tests_properties(coverage-unknown-arg PROPERTIES
  TIMEOUT   30
  LABELS    cmake-only
  WILL_FAIL TRUE)

# coverage: optional SOURCE_DIR argument is accepted and the target is created.
add_test(
  NAME coverage-source-dir-target
  COMMAND ${CMAKE_COMMAND}
    -S "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-coverage"
    -B "${CMAKE_BINARY_DIR}/coverage-source-dir-target-build"
    "-DMODULES_DIR=${MODULES_DIR}"
    -DRUN_SOURCE_DIR_REPORT_TARGET=ON
    -DCMAKE_CXX_COMPILER_ID=GNU
)
set_tests_properties(coverage-source-dir-target PROPERTIES
  TIMEOUT 30
  LABELS  cmake-only)

# coverage: omitting SOURCE_DIR still creates the target (backward compat).
add_test(
  NAME coverage-no-source-dir-compat
  COMMAND ${CMAKE_COMMAND}
    -S "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-coverage"
    -B "${CMAKE_BINARY_DIR}/coverage-no-source-dir-build"
    "-DMODULES_DIR=${MODULES_DIR}"
    -DRUN_NO_SOURCE_DIR=ON
    -DCMAKE_CXX_COMPILER_ID=GNU
)
set_tests_properties(coverage-no-source-dir-compat PROPERTIES
  TIMEOUT 30
  LABELS  cmake-only)

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
  # COMPILER_ID sets the simulated compiler id: the C++ id by default, or the C
  # id when the C flag is given (to exercise the C-only fallback path).
  cmake_parse_arguments(SC "WILL_FAIL;C" "COMPILER_ID" "" ${ARGN})
  set(_args
    -S "${CMAKE_CURRENT_SOURCE_DIR}/cmake-only/test-sanitizers"
    -B "${CMAKE_BINARY_DIR}/sanitizers-${case}-build"
    "-DMODULES_DIR=${MODULES_DIR}"
    "-DTEST_CASE=${case}")
  if(SC_COMPILER_ID)
    list(APPEND _args "-DSIMULATED_COMPILER_ID=${SC_COMPILER_ID}")
    if(SC_C)
      list(APPEND _args "-DSIMULATED_C=ON")
    endif()
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
# C-only project: empty CXX id, C id drives the per-compiler branch.
_add_sanitizers_case(c-gnu-address-undefined   COMPILER_ID GNU   C)
_add_sanitizers_case(c-clang-address-undefined COMPILER_ID Clang C)
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
# The single consumer in integration/mylib is configured as C++ here and as C
# below; both chains build → test → coverage via CTest fixtures.
# ---------------------------------------------------------------------------
add_test(
  NAME integration-configure
  COMMAND ${CMAKE_COMMAND}
    -S "${CMAKE_CURRENT_SOURCE_DIR}/integration/mylib"
    -B "${CMAKE_BINARY_DIR}/mylib-build"
    "-DMODULES_DIR=${MODULES_DIR}"
    -DCONSUMER_LANG=CXX
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

# ---------------------------------------------------------------------------
# C integration tests (Clang) — same consumer configured as a C project, to
# exercise the C compiler-id path in coverage.cmake/sanitizers.cmake. The
# language-agnostic install/package machinery is already covered by the C++
# chain above, so this chain stops at coverage. Names start with
# "integration-c-" so the Clang CI job picks them up.
# ---------------------------------------------------------------------------
add_test(
  NAME integration-c-configure
  COMMAND ${CMAKE_COMMAND}
    -S "${CMAKE_CURRENT_SOURCE_DIR}/integration/mylib"
    -B "${CMAKE_BINARY_DIR}/mylib-c-build"
    "-DMODULES_DIR=${MODULES_DIR}"
    -DCONSUMER_LANG=C
    -DCMAKE_BUILD_TYPE=Debug
    -DCMAKE_C_COMPILER=clang
)
add_test(
  NAME integration-c-build
  COMMAND ${CMAKE_COMMAND} --build "${CMAKE_BINARY_DIR}/mylib-c-build" --parallel
)
add_test(
  NAME integration-c-test
  COMMAND ${CMAKE_CTEST_COMMAND}
    --test-dir "${CMAKE_BINARY_DIR}/mylib-c-build"
    --output-on-failure
)
add_test(
  NAME integration-c-coverage
  COMMAND ${CMAKE_COMMAND}
    --build "${CMAKE_BINARY_DIR}/mylib-c-build"
    --target coverage
)

set_tests_properties(integration-c-configure PROPERTIES
  FIXTURES_SETUP    mylib_c_configured
  TIMEOUT           120
  LABELS            integration)
set_tests_properties(integration-c-build PROPERTIES
  FIXTURES_REQUIRED mylib_c_configured
  FIXTURES_SETUP    mylib_c_built
  TIMEOUT           300
  LABELS            integration)
set_tests_properties(integration-c-test PROPERTIES
  FIXTURES_REQUIRED mylib_c_built
  FIXTURES_SETUP    mylib_c_tested
  TIMEOUT           120
  LABELS            integration)
set_tests_properties(integration-c-coverage PROPERTIES
  FIXTURES_REQUIRED mylib_c_tested
  TIMEOUT           120
  LABELS            integration)

# ---------------------------------------------------------------------------
# GCC integration tests — same consumer as C++, different compiler + gcovr
# ---------------------------------------------------------------------------
add_test(
  NAME integration-gcc-configure
  COMMAND ${CMAKE_COMMAND}
    -S "${CMAKE_CURRENT_SOURCE_DIR}/integration/mylib"
    -B "${CMAKE_BINARY_DIR}/mylib-gcc-build"
    "-DMODULES_DIR=${MODULES_DIR}"
    -DCONSUMER_LANG=CXX
    -DCMAKE_BUILD_TYPE=Debug
    -DCMAKE_C_COMPILER=gcc
    -DCMAKE_CXX_COMPILER=g++
)
add_test(
  NAME integration-gcc-build
  COMMAND ${CMAKE_COMMAND} --build "${CMAKE_BINARY_DIR}/mylib-gcc-build" --parallel
)
add_test(
  NAME integration-gcc-test
  COMMAND ${CMAKE_CTEST_COMMAND}
    --test-dir "${CMAKE_BINARY_DIR}/mylib-gcc-build"
    --output-on-failure
)
add_test(
  NAME integration-gcc-coverage
  COMMAND ${CMAKE_COMMAND}
    --build "${CMAKE_BINARY_DIR}/mylib-gcc-build"
    --target coverage
)

set_tests_properties(integration-gcc-configure PROPERTIES
  FIXTURES_SETUP    mylib_gcc_configured
  TIMEOUT           120
  LABELS            integration)
set_tests_properties(integration-gcc-build PROPERTIES
  FIXTURES_REQUIRED mylib_gcc_configured
  FIXTURES_SETUP    mylib_gcc_built
  TIMEOUT           300
  LABELS            integration)
set_tests_properties(integration-gcc-test PROPERTIES
  FIXTURES_REQUIRED mylib_gcc_built
  FIXTURES_SETUP    mylib_gcc_tested
  TIMEOUT           120
  LABELS            integration)
set_tests_properties(integration-gcc-coverage PROPERTIES
  FIXTURES_REQUIRED mylib_gcc_tested
  TIMEOUT           120
  LABELS            integration)

# ---------------------------------------------------------------------------
# C integration tests (GCC) — same consumer configured as a C project, GCC +
# gcovr. Names start with "integration-gcc-" so the GCC CI job picks them up.
# ---------------------------------------------------------------------------
add_test(
  NAME integration-gcc-c-configure
  COMMAND ${CMAKE_COMMAND}
    -S "${CMAKE_CURRENT_SOURCE_DIR}/integration/mylib"
    -B "${CMAKE_BINARY_DIR}/mylib-c-gcc-build"
    "-DMODULES_DIR=${MODULES_DIR}"
    -DCONSUMER_LANG=C
    -DCMAKE_BUILD_TYPE=Debug
    -DCMAKE_C_COMPILER=gcc
)
add_test(
  NAME integration-gcc-c-build
  COMMAND ${CMAKE_COMMAND} --build "${CMAKE_BINARY_DIR}/mylib-c-gcc-build" --parallel
)
add_test(
  NAME integration-gcc-c-test
  COMMAND ${CMAKE_CTEST_COMMAND}
    --test-dir "${CMAKE_BINARY_DIR}/mylib-c-gcc-build"
    --output-on-failure
)
add_test(
  NAME integration-gcc-c-coverage
  COMMAND ${CMAKE_COMMAND}
    --build "${CMAKE_BINARY_DIR}/mylib-c-gcc-build"
    --target coverage
)

set_tests_properties(integration-gcc-c-configure PROPERTIES
  FIXTURES_SETUP    mylib_c_gcc_configured
  TIMEOUT           120
  LABELS            integration)
set_tests_properties(integration-gcc-c-build PROPERTIES
  FIXTURES_REQUIRED mylib_c_gcc_configured
  FIXTURES_SETUP    mylib_c_gcc_built
  TIMEOUT           300
  LABELS            integration)
set_tests_properties(integration-gcc-c-test PROPERTIES
  FIXTURES_REQUIRED mylib_c_gcc_built
  FIXTURES_SETUP    mylib_c_gcc_tested
  TIMEOUT           120
  LABELS            integration)
set_tests_properties(integration-gcc-c-coverage PROPERTIES
  FIXTURES_REQUIRED mylib_c_gcc_tested
  TIMEOUT           120
  LABELS            integration)
