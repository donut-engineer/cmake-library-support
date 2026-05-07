cmake_minimum_required(VERSION 3.15)
project(test-install-rules LANGUAGES NONE VERSION 1.0.0)

list(APPEND CMAKE_MODULE_PATH "${MODULES_DIR}")
set(CMAKE_LIBRARY_SUPPORT_DIR "${MODULES_DIR}" CACHE INTERNAL "" FORCE)
include(config-template)
include(install-rules)

# ---------------------------------------------------------------------------
# Test: INTERFACE_TARGET only — no compiler needed for INTERFACE libraries.
# Verifies that omitting STATIC_TARGET and SHARED_TARGET is accepted and that
# configure_package_config_file runs and produces the expected output files.
# ---------------------------------------------------------------------------
generate_config_template(PACKAGE_NAME "mylib" INTERFACE)
add_library(mylib INTERFACE)
library_install_rules(PACKAGE_NAME mylib NAMESPACE mylib INTERFACE_TARGET mylib)

if(NOT EXISTS "${PROJECT_BINARY_DIR}/mylib-config.cmake")
    message(FATAL_ERROR "mylib-config.cmake was not generated")
endif()
if(NOT EXISTS "${PROJECT_BINARY_DIR}/mylib-config-version.cmake")
    message(FATAL_ERROR "mylib-config-version.cmake was not generated")
endif()
