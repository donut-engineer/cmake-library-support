cmake_minimum_required(VERSION 3.15)
project(test-coverage NONE)

list(APPEND CMAKE_MODULE_PATH "${MODULES_DIR}")
include(coverage)

# ---------------------------------------------------------------------------
# Test: unsupported compiler produces FATAL_ERROR in add_coverage_report_target.
# CMAKE_CXX_COMPILER_ID is set via -D because LANGUAGES NONE skips detection.
# An IMPORTED EXECUTABLE stands in for the real test binary; cmake accepts it
# in generator expressions without requiring a real build-system target.
# ---------------------------------------------------------------------------
if(TEST_UNKNOWN_COMPILER)
    add_executable(dummy IMPORTED)
    set_target_properties(dummy PROPERTIES IMPORTED_LOCATION "/usr/bin/true")
    add_coverage_report_target(TEST_TARGET dummy)
endif()
