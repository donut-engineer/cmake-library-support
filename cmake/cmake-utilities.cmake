# cmake-utilities.cmake
# Entry point for the cmake-utilities module collection.
#
# Usage (via FetchContent):
#   include(FetchContent)
#   FetchContent_Declare(cmake_utilities
#       GIT_REPOSITORY git@github.com:donut-engineer/cmake-utilities.git
#       GIT_TAG main
#   )
#   FetchContent_MakeAvailable(cmake_utilities)
#   include(${cmake_utilities_SOURCE_DIR}/cmake/cmake-utilities.cmake)

# Guard against multiple inclusions
if(DEFINED CMAKE_UTILITIES_DIR)
    return()
endif()

set(CMAKE_UTILITIES_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL
    "Path to cmake-utilities cmake/ directory")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_UTILITIES_DIR}")
