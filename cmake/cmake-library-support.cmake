# cmake-library-support.cmake
# Entry point for the cmake-library-support module collection.
#
# Usage (via FetchContent):
#   include(FetchContent)
#   FetchContent_Declare(cmake_library_support
#       GIT_REPOSITORY https://github.com/donut-engineer/cmake-library-support.git
#       GIT_TAG v2.0.0
#   )
#   FetchContent_MakeAvailable(cmake_library_support)
#   include(${cmake_library_support_SOURCE_DIR}/cmake/cmake-library-support.cmake)

if(CMAKE_VERSION VERSION_LESS "3.15")
    message(FATAL_ERROR "cmake-library-support requires CMake 3.15 or higher (found ${CMAKE_VERSION})")
endif()

set(CMAKE_LIBRARY_SUPPORT_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL
    "Path to cmake-library-support cmake/ directory")

if(NOT "${CMAKE_LIBRARY_SUPPORT_DIR}" IN_LIST CMAKE_MODULE_PATH)
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_LIBRARY_SUPPORT_DIR}")
endif()
