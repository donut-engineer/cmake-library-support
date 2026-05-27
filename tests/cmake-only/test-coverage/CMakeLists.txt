cmake_minimum_required(VERSION 3.15)
project(test-coverage NONE)

list(APPEND CMAKE_MODULE_PATH "${MODULES_DIR}")
include(coverage)

# ---------------------------------------------------------------------------
# Exercises add_coverage_report_target with a stand-in IMPORTED executable (cmake
# accepts it in generator expressions without a real build-system target). The
# caller sets the compiler id via -D (LANGUAGES NONE skips detection) and chooses
# whether the case should pass or fail:
#   - unsupported CMAKE_CXX_COMPILER_ID    → compiler guard FATAL_ERRORs (WILL_FAIL)
#   - C-only project (C id, empty CXX id)  → guard falls back to the C id and passes
# gcovr need not be installed: the guard runs before find_program(), so reaching
# the (warn-and-return) gcovr lookup already proves the guard accepted the compiler.
# ---------------------------------------------------------------------------
if(RUN_REPORT_TARGET)
    add_executable(dummy IMPORTED)
    set_target_properties(dummy PROPERTIES IMPORTED_LOCATION "/usr/bin/true")
    add_coverage_report_target(TEST_TARGET dummy)
endif()
