cmake_minimum_required(VERSION 3.21)
project(cmake-utilities-smoke VERSION 1.0.0 LANGUAGES NONE)

include(${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/cmake-utilities.cmake)
include(find-modules)
include(config-template)
include(package-rules)

# GNUInstallDirs (pulled in by install-rules) cannot detect the lib dir when
# no language is enabled; set a sensible default to suppress the warning.
set(CMAKE_INSTALL_LIBDIR "lib" CACHE PATH "")
include(install-rules)

# --- generate_find_module ---
generate_find_module(
    MODULE_NAME "Smoke"
    NAMESPACE   "Smoke"
    TARGET_NAME "smoke"
    PACKAGE_DOC "smoke-lib"
    HEADER_NAME "smoke/api.hpp"
)
if(NOT EXISTS "${PROJECT_BINARY_DIR}/cmake/FindSmoke.cmake")
    message(FATAL_ERROR "generate_find_module did not create FindSmoke.cmake")
endif()
message(STATUS "PASS: generate_find_module")

# --- generate_config_template (must precede library_install_rules) ---
generate_config_template(PACKAGE_NAME "smoke-lib")
if(NOT EXISTS "${PROJECT_BINARY_DIR}/cmake/smoke-lib-config.cmake.in")
    message(FATAL_ERROR "generate_config_template did not create smoke-lib-config.cmake.in")
endif()
message(STATUS "PASS: generate_config_template")

# --- library_package_rules ---
library_package_rules(
    PACKAGE_NAME "smoke-lib"
    DESCRIPTION  "Smoke test library"
)
message(STATUS "PASS: library_package_rules")

# --- library_install_rules ---
# INTERFACE targets require no compiler; CMake silently ignores ARCHIVE/LIBRARY
# destinations for them, so this exercises the install rule logic without a
# C++ toolchain.
add_library(smoke-static    INTERFACE)
add_library(smoke-shared    INTERFACE)
add_library(smoke-interface INTERFACE)

library_install_rules(
    PACKAGE_NAME     "smoke-lib"
    NAMESPACE        "Smoke"
    STATIC_TARGET    smoke-static
    SHARED_TARGET    smoke-shared
    INTERFACE_TARGET smoke-interface
)
message(STATUS "PASS: library_install_rules")
