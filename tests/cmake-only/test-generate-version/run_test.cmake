# run_test.cmake — invoked via cmake -P
# Required -D arguments:
#   MODULES_DIR  — path to the cmake/ directory of cmake-library-support
#   SOURCE_DIR   — path to the git repo root (used by generate-version.cmake for git commands)
#   BINARY_DIR   — writable temp directory for output
#   TEST_DIR     — path to this test's source directory (contains version.h.in)

if(NOT MODULES_DIR OR NOT SOURCE_DIR OR NOT BINARY_DIR OR NOT TEST_DIR)
  message(FATAL_ERROR "run_test.cmake: MODULES_DIR, SOURCE_DIR, BINARY_DIR, and TEST_DIR are required")
endif()

set(TEMPLATE "${TEST_DIR}/version.h.in")
set(OUTPUT   "${BINARY_DIR}/version.h")

file(MAKE_DIRECTORY "${BINARY_DIR}")

execute_process(
  COMMAND ${CMAKE_COMMAND}
    "-DSOURCE_DIR=${SOURCE_DIR}"
    "-DVERSION=2.5.0"
    "-DTEMPLATE=${TEMPLATE}"
    "-DOUTPUT=${OUTPUT}"
    -P "${MODULES_DIR}/generate-version.cmake"
  RESULT_VARIABLE _result
  OUTPUT_VARIABLE _output
  ERROR_VARIABLE  _error
)

if(NOT _result EQUAL 0)
  message(FATAL_ERROR "generate-version.cmake exited with ${_result}\nstdout: ${_output}\nstderr: ${_error}")
endif()

if(NOT EXISTS "${OUTPUT}")
  message(FATAL_ERROR "Output file was not created: ${OUTPUT}")
endif()

file(READ "${OUTPUT}" _content)

# @VERSION_FULL@ placeholder must have been substituted (not left as-is)
if(_content MATCHES "@VERSION_FULL@")
  message(FATAL_ERROR "@VERSION_FULL@ was not substituted in output:\n${_content}")
endif()

# Determine expected version string the same way generate-version.cmake does
execute_process(
  COMMAND git rev-parse --abbrev-ref HEAD
  OUTPUT_VARIABLE _branch
  OUTPUT_STRIP_TRAILING_WHITESPACE
  WORKING_DIRECTORY "${SOURCE_DIR}"
  ERROR_QUIET
)
if(_branch STREQUAL "release")
  set(_expected_version "2.5.0")
else()
  execute_process(
    COMMAND git rev-parse --short HEAD
    OUTPUT_VARIABLE _commit
    OUTPUT_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY "${SOURCE_DIR}"
    ERROR_QUIET
  )
  if(NOT _commit)
    set(_commit "unknown")
  endif()
  execute_process(
    COMMAND git status --porcelain
    OUTPUT_VARIABLE _status
    OUTPUT_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY "${SOURCE_DIR}"
    ERROR_QUIET
  )
  if(_status STREQUAL "")
    set(_expected_version "2.5.0-${_commit}")
  else()
    set(_expected_version "2.5.0-${_commit}-dirty")
  endif()
endif()

if(NOT _content MATCHES "${_expected_version}")
  message(FATAL_ERROR "Expected version '${_expected_version}' not found in generated output:\n${_content}")
endif()
