cmake_minimum_required(VERSION 3.14)
project(test-cmake-library-support NONE)

list(APPEND CMAKE_MODULE_PATH "${MODULES_DIR}")
include(cmake-library-support)

if(NOT CMAKE_LIBRARY_SUPPORT_DIR)
  message(FATAL_ERROR "CMAKE_LIBRARY_SUPPORT_DIR was not set by cmake-library-support.cmake")
endif()

if(NOT EXISTS "${CMAKE_LIBRARY_SUPPORT_DIR}/cmake-library-support.cmake")
  message(FATAL_ERROR "CMAKE_LIBRARY_SUPPORT_DIR does not point to a valid directory: ${CMAKE_LIBRARY_SUPPORT_DIR}")
endif()

# Verify CMAKE_MODULE_PATH contains the support dir
list(FIND CMAKE_MODULE_PATH "${CMAKE_LIBRARY_SUPPORT_DIR}" _idx)
if(_idx EQUAL -1)
  message(FATAL_ERROR "CMAKE_LIBRARY_SUPPORT_DIR not found in CMAKE_MODULE_PATH")
endif()

# Double-include must be idempotent (no duplicate MODULE_PATH entries)
include(cmake-library-support)
list(REMOVE_DUPLICATES CMAKE_MODULE_PATH)
list(FIND CMAKE_MODULE_PATH "${CMAKE_LIBRARY_SUPPORT_DIR}" _idx2)
if(_idx2 EQUAL -1)
  message(FATAL_ERROR "CMAKE_LIBRARY_SUPPORT_DIR lost from CMAKE_MODULE_PATH after re-include")
endif()
