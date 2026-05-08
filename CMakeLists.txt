cmake_minimum_required(VERSION 3.15)
project(cmake-library-support NONE)

set(CMAKE_LIBRARY_SUPPORT_DIR "${CMAKE_CURRENT_LIST_DIR}/cmake" CACHE INTERNAL
    "Path to cmake-library-support cmake/ directory" FORCE)

if(NOT "${CMAKE_LIBRARY_SUPPORT_DIR}" IN_LIST CMAKE_MODULE_PATH)
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_LIBRARY_SUPPORT_DIR}")
    # Propagate to the consumer's scope when consumed via FetchContent_MakeAvailable()
    set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)
endif()
