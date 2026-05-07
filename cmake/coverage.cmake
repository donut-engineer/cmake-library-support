# Adds Clang source-based coverage compile and link flags to the given target
function(target_enable_coverage)
    cmake_parse_arguments(ARG "" "TARGET" "" ${ARGN})
    if(NOT ARG_TARGET)
        message(FATAL_ERROR "target_enable_coverage: TARGET is required")
    endif()
    target_compile_options(${ARG_TARGET} PRIVATE -fprofile-instr-generate -fcoverage-mapping)
    target_link_options(${ARG_TARGET} PRIVATE -fprofile-instr-generate)
endfunction()

# Creates a 'coverage' custom target that:
#   1. Runs tests via CTest, capturing raw profile data
#   2. Merges profiles with llvm-profdata
#   3. Generates an HTML report with llvm-cov, excluding third-party paths
#      (googletest, googlemock) and system headers
#   4. Prints a line coverage summary to stdout
#   5. Fails the build if line coverage is below 100%
#
# Required argument:
#   TEST_TARGET    — the CMake test executable target (must be built before running)
#
# Optional argument:
#   EXCLUDE_REGEX  — regex passed to -ignore-filename-regex (matched against full file
#                    paths). Defaults to excluding googletest, googlemock, /usr/, and
#                    any path containing /tests/.
function(add_coverage_report_target)
    cmake_parse_arguments(ARG "" "TEST_TARGET;EXCLUDE_REGEX" "" ${ARGN})

    if(NOT ARG_TEST_TARGET)
        message(FATAL_ERROR "add_coverage_report_target: TEST_TARGET is required")
    endif()

    if(NOT ARG_EXCLUDE_REGEX)
        set(ARG_EXCLUDE_REGEX ".*/googletest/.*|.*/googlemock/.*|/usr/.*|.*/tests/.*")
    endif()

    find_program(LLVM_PROFDATA_EXE NAMES llvm-profdata-18 llvm-profdata)
    find_program(LLVM_COV_EXE     NAMES llvm-cov-18      llvm-cov)

    if(NOT LLVM_PROFDATA_EXE)
        message(WARNING "llvm-profdata not found — 'coverage' target will not be available")
        return()
    endif()

    if(NOT LLVM_COV_EXE)
        message(WARNING "llvm-cov not found — 'coverage' target will not be available")
        return()
    endif()

    set(COVERAGE_DIR     "${CMAKE_BINARY_DIR}/coverage")
    set(PROFRAW_PATTERN  "${COVERAGE_DIR}/coverage-%p.profraw")
    set(PROFDATA_FILE    "${COVERAGE_DIR}/coverage.profdata")
    set(TEST_EXE         "$<TARGET_FILE:${ARG_TEST_TARGET}>")

    add_custom_target(coverage
        VERBATIM
        COMMENT "Running tests and generating coverage report"
        # Ensure output directory exists
        COMMAND ${CMAKE_COMMAND} -E make_directory "${COVERAGE_DIR}"
        # Run tests; LLVM_PROFILE_FILE tells the runtime where to write raw data.
        # %p expands to the process ID so parallel test processes don't collide.
        COMMAND ${CMAKE_COMMAND} -E env
            "LLVM_PROFILE_FILE=${PROFRAW_PATTERN}"
            ${CMAKE_CTEST_COMMAND} --output-on-failure
        # Merge all raw profiles into a single indexed .profdata file.
        # bash -c is used so the shell expands the coverage-*.profraw glob.
        COMMAND bash -c
            "${LLVM_PROFDATA_EXE} merge -sparse ${COVERAGE_DIR}/coverage-*.profraw -o ${PROFDATA_FILE}"
        # Generate HTML report, excluding third-party and system paths
        COMMAND ${LLVM_COV_EXE} show
            "${TEST_EXE}"
            "-instr-profile=${PROFDATA_FILE}"
            "-format=html"
            "-output-dir=${COVERAGE_DIR}/html"
            "-ignore-filename-regex=${ARG_EXCLUDE_REGEX}"
        # Print a line coverage summary to stdout and save for the 100% check.
        # bash -c is used so the shell handles the | pipe to tee.
        # The regex value is single-quoted so its | alternators are not treated as pipes.
        COMMAND bash -c
            "${LLVM_COV_EXE} report ${TEST_EXE} -instr-profile=${PROFDATA_FILE} '-ignore-filename-regex=${ARG_EXCLUDE_REGEX}' | tee ${COVERAGE_DIR}/report.txt"
        # Fail if line coverage (4th-from-last column of the TOTAL row) is not 100.00%.
        # The report columns are: Regions Missed Cover | Functions Missed Executed | Lines Missed Cover | Branches Missed Cover
        # $(NF-3) selects the Lines Cover column regardless of whether branch data is present.
        COMMAND bash -c
            "awk '/^TOTAL/{ if (\$(NF-3) != \"100.00%\" && \$(NF-3) != \"-\") { print \"ERROR: line coverage \" \$(NF-3) \" — 100.00% required\"; exit 1 } }' ${COVERAGE_DIR}/report.txt"
        COMMAND ${CMAKE_COMMAND} -E echo
            "Coverage report: ${COVERAGE_DIR}/html/index.html"
        WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
        DEPENDS ${ARG_TEST_TARGET}
    )
endfunction()
