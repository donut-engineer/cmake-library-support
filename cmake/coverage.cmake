# Adds coverage compile and link flags to the given target.
# Supports GNU (--coverage) and Clang/AppleClang (--coverage).
function(target_enable_coverage)
    cmake_parse_arguments(ARG "" "TARGET" "" ${ARGN})
    if(NOT ARG_TARGET)
        message(FATAL_ERROR "target_enable_coverage: TARGET is required")
    endif()
    # Prefer the C++ compiler ID; fall back to C so C-only projects work too.
    if(CMAKE_CXX_COMPILER_ID)
        set(_compiler_id "${CMAKE_CXX_COMPILER_ID}")
    else()
        set(_compiler_id "${CMAKE_C_COMPILER_ID}")
    endif()
    if(NOT _compiler_id MATCHES "^(GNU|Clang|AppleClang)$")
        message(FATAL_ERROR
            "target_enable_coverage: unsupported compiler '${_compiler_id}' "
            "(supported: GNU, Clang, AppleClang)")
    endif()
    target_compile_options(${ARG_TARGET} PRIVATE --coverage)
    target_link_options(${ARG_TARGET} PRIVATE --coverage)
endfunction()

# Creates a custom target (named 'coverage' by default) that:
#   1. Runs tests via CTest; --coverage instrumentation writes .gcda files automatically
#   2. Generates an HTML report with gcovr, excluding third-party paths
#      (googletest, googlemock) and system headers
#   3. Prints a line coverage summary to stdout
#   4. Fails the build if line coverage is below 100%
#
# Requires gcovr (https://gcovr.com, BSD-3-Clause). Install via pip: pip install gcovr
# Clang/AppleClang additionally requires llvm-cov for the gcov backend.
#
# Required argument:
#   TEST_TARGET    — the CMake test executable target (must be built before running)
#
# Optional arguments:
#   NAME           — name of the custom target to create. Defaults to "coverage".
#                    The HTML report is written to "${CMAKE_BINARY_DIR}/<NAME>/html",
#                    so distinct names allow multiple independent report targets.
#   EXCLUDE_REGEX  — regex passed to gcovr --exclude (matched against full file paths).
#                    Defaults to excluding googletest, googlemock, /usr/, and any path
#                    containing a directory named "test".
#   SEARCH_DIR     — path passed to gcovr as the .gcda search root.
#                    Defaults to CMAKE_BINARY_DIR. Set to a library's own binary dir
#                    when multiple libraries share a build tree to avoid
#                    cross-contamination of coverage data.
#
# Note: the generated target runs ctest with WORKING_DIRECTORY set to
# CMAKE_CURRENT_BINARY_DIR (the calling library's binary dir at configure time).
# CTest reads CTestTestfile.cmake from that directory, scoping test execution to
# the tests registered in that subdirectory only.
function(add_coverage_report_target)
    cmake_parse_arguments(ARG "" "TEST_TARGET;EXCLUDE_REGEX;NAME;SEARCH_DIR" "" ${ARGN})

    if(ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR
            "add_coverage_report_target: unrecognized arguments: ${ARG_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT ARG_TEST_TARGET)
        message(FATAL_ERROR "add_coverage_report_target: TEST_TARGET is required")
    endif()

    if(NOT ARG_NAME)
        set(ARG_NAME coverage)
    endif()

    if(NOT ARG_SEARCH_DIR)
        set(ARG_SEARCH_DIR "${CMAKE_BINARY_DIR}")
    endif()

    # Prefer the C++ compiler ID; fall back to C so C-only projects work too.
    if(CMAKE_CXX_COMPILER_ID)
        set(_compiler_id "${CMAKE_CXX_COMPILER_ID}")
    else()
        set(_compiler_id "${CMAKE_C_COMPILER_ID}")
    endif()
    if(NOT _compiler_id MATCHES "^(GNU|Clang|AppleClang)$")
        message(FATAL_ERROR
            "add_coverage_report_target: unsupported compiler '${_compiler_id}' "
            "(supported: GNU, Clang, AppleClang)")
    endif()

    if(NOT ARG_EXCLUDE_REGEX)
        set(ARG_EXCLUDE_REGEX ".*/googletest/.*|.*/googlemock/.*|/usr/.*|.*/test/.*")
    endif()

    find_program(GCOVR_EXE NAMES gcovr)
    if(NOT GCOVR_EXE)
        message(WARNING "gcovr not found — '${ARG_NAME}' target will not be available")
        return()
    endif()

    # Clang/AppleClang use llvm-cov as the gcov backend; GNU uses the system gcov.
    set(_gcov_executable_arg "")
    if(_compiler_id MATCHES "^(Clang|AppleClang)$")
        find_program(LLVM_COV_EXE NAMES llvm-cov-18 llvm-cov)
        if(NOT LLVM_COV_EXE)
            message(WARNING "llvm-cov not found — '${ARG_NAME}' target will not be available")
            return()
        endif()
        set(_gcov_executable_arg "--gcov-executable" "${LLVM_COV_EXE} gcov")
    endif()

    set(COVERAGE_DIR "${CMAKE_BINARY_DIR}/${ARG_NAME}")

    add_custom_target(${ARG_NAME}
        VERBATIM
        COMMENT "Running tests and generating coverage report"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${COVERAGE_DIR}/html"
        # Run tests; --coverage instrumentation writes .gcda files next to object files.
        COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
        # Generate HTML report and enforce 100% line coverage.
        # gcovr --exclude accepts the same alternation regex as EXCLUDE_REGEX.
        # _gcov_executable_arg is empty for GNU (uses system gcov) or
        # "--gcov-executable <llvm-cov> gcov" for Clang/AppleClang.
        COMMAND ${GCOVR_EXE}
            ${_gcov_executable_arg}
            "--root" "${CMAKE_SOURCE_DIR}"
            "--exclude" "${ARG_EXCLUDE_REGEX}"
            "--html-details" "${COVERAGE_DIR}/html/index.html"
            "--print-summary"
            "--fail-under-line" "100"
            "${ARG_SEARCH_DIR}"
        COMMAND ${CMAKE_COMMAND} -E echo
            "Coverage report: ${COVERAGE_DIR}/html/index.html"
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        DEPENDS ${ARG_TEST_TARGET}
    )
endfunction()
