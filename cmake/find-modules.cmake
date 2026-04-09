# Generates Find*.cmake modules at configure time into ${PROJECT_BINARY_DIR}/cmake/.
# These are installed alongside the library so downstream consumers can use
# module-mode find_package().

# Generates a FindXxxStatic.cmake module for a static library.
#
# Required arguments:
#   MODULE_NAME  — find-module name without "Find" prefix (e.g. "BehaviorTreeStatic")
#   NAMESPACE    — CMake namespace for the imported target (e.g. "BehaviorTree")
#   TARGET_NAME  — imported target name without namespace (e.g. "behaviorTree")
#   HEADER_NAME  — header path to locate via find_path (e.g. "behaviorTree/iNode.hpp")
#   PACKAGE_DOC  — human-readable package name for docs (e.g. "behavior-tree")
function(generate_find_module)
    cmake_parse_arguments(ARG "" "MODULE_NAME;NAMESPACE;TARGET_NAME;HEADER_NAME;PACKAGE_DOC" "" ${ARGN})

    if(NOT ARG_MODULE_NAME OR NOT ARG_NAMESPACE OR NOT ARG_TARGET_NAME OR NOT ARG_HEADER_NAME OR NOT ARG_PACKAGE_DOC)
        message(FATAL_ERROR "generate_find_static_module requires MODULE_NAME, NAMESPACE, TARGET_NAME, HEADER_NAME, and PACKAGE_DOC")
    endif()

    set(_out "${PROJECT_BINARY_DIR}/cmake/Find${ARG_MODULE_NAME}.cmake")

    configure_file(
        "${CMAKE_CURRENT_LIST_DIR}/FindModule.cmake.in"
        "${_out}"
        @ONLY
    )
endfunction()