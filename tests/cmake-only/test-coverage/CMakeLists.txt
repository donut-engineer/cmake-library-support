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

# ---------------------------------------------------------------------------
# Verifies the optional NAME argument: the custom target is created under the
# given name (not the default 'coverage'). Pre-seeding GCOVR_EXE short-circuits
# the find_program() lookup so the function reaches add_custom_target without a
# real gcovr install (the cmake-only CI matrix has none). GNU is used so the
# llvm-cov backend lookup is skipped. 'dummy' is a real custom target so it is a
# valid add_custom_target DEPENDS once the function proceeds.
# ---------------------------------------------------------------------------
if(RUN_NAMED_REPORT_TARGET)
    add_custom_target(dummy)
    set(GCOVR_EXE "/usr/bin/true" CACHE FILEPATH "" FORCE)
    add_coverage_report_target(TEST_TARGET dummy NAME custom-coverage)
    if(NOT TARGET custom-coverage)
        message(FATAL_ERROR "expected 'custom-coverage' target to be created")
    endif()
    if(TARGET coverage)
        message(FATAL_ERROR "default-named 'coverage' target should not exist when NAME is set")
    endif()
endif()

# ---------------------------------------------------------------------------
# Verifies that unknown keyword arguments are rejected with a FATAL_ERROR.
# ---------------------------------------------------------------------------
if(RUN_UNKNOWN_ARG)
    add_custom_target(dummy)
    set(GCOVR_EXE "/usr/bin/true" CACHE FILEPATH "" FORCE)
    add_coverage_report_target(TEST_TARGET dummy BOGUS_ARG value)
endif()

# ---------------------------------------------------------------------------
# Verifies the optional SOURCE_DIR argument: the custom target is created and
# the argument is accepted without error. Pre-seeding GCOVR_EXE skips the
# find_program() lookup so no real gcovr install is required.
# ---------------------------------------------------------------------------
if(RUN_SOURCE_DIR_REPORT_TARGET)
    add_custom_target(dummy)
    set(GCOVR_EXE "/usr/bin/true" CACHE FILEPATH "" FORCE)
    add_coverage_report_target(
        TEST_TARGET dummy
        NAME        coverage-srcdir
        SOURCE_DIR  "${CMAKE_CURRENT_SOURCE_DIR}"
    )
    if(NOT TARGET coverage-srcdir)
        message(FATAL_ERROR "expected 'coverage-srcdir' target to be created")
    endif()
endif()

# ---------------------------------------------------------------------------
# Backward-compat: omitting SOURCE_DIR still creates the target.
# ---------------------------------------------------------------------------
if(RUN_NO_SOURCE_DIR)
    add_custom_target(dummy)
    set(GCOVR_EXE "/usr/bin/true" CACHE FILEPATH "" FORCE)
    add_coverage_report_target(TEST_TARGET dummy NAME coverage-no-srcdir)
    if(NOT TARGET coverage-no-srcdir)
        message(FATAL_ERROR "expected 'coverage-no-srcdir' target to be created")
    endif()
endif()
