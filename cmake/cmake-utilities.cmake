# cmake-utilities.cmake
# Entry point for the cmake-utilities module collection.
#
# Usage (via FetchContent):
#   include(FetchContent)
#   FetchContent_Declare(cmake_utilities
#       GIT_REPOSITORY https://github.com/tcarter690/cmake-utilities.git
#       GIT_TAG main
#   )
#   FetchContent_MakeAvailable(cmake_utilities)
#   include(${cmake_utilities_SOURCE_DIR}/cmake/cmake-utilities.cmake)

set(CMAKE_UTILITIES_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL
    "Path to cmake-utilities cmake/ directory")

if(NOT "${CMAKE_UTILITIES_DIR}" IN_LIST CMAKE_MODULE_PATH)
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_UTILITIES_DIR}")
endif()
