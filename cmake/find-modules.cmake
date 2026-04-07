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
function(generate_find_static_module)
    cmake_parse_arguments(ARG "" "MODULE_NAME;NAMESPACE;TARGET_NAME;HEADER_NAME;PACKAGE_DOC" "" ${ARGN})

    if(NOT ARG_MODULE_NAME OR NOT ARG_NAMESPACE OR NOT ARG_TARGET_NAME OR NOT ARG_HEADER_NAME OR NOT ARG_PACKAGE_DOC)
        message(FATAL_ERROR "generate_find_static_module requires MODULE_NAME, NAMESPACE, TARGET_NAME, HEADER_NAME, and PACKAGE_DOC")
    endif()

    set(_out "${PROJECT_BINARY_DIR}/cmake/Find${ARG_MODULE_NAME}.cmake")

    file(WRITE "${_out}"
"# Find${ARG_MODULE_NAME}.cmake
# ----------------------------
# Finds the ${ARG_PACKAGE_DOC} static library.
#
# Imported targets:
#   ${ARG_NAMESPACE}::${ARG_TARGET_NAME} - static library
#
# Cache variables:
#   ${ARG_MODULE_NAME}_INCLUDE_DIR - directory containing ${ARG_HEADER_NAME}
#   ${ARG_MODULE_NAME}_LIBRARY     - path to lib${ARG_TARGET_NAME}.a

cmake_minimum_required(VERSION 3.25)

find_path(${ARG_MODULE_NAME}_INCLUDE_DIR
    NAMES ${ARG_HEADER_NAME}
    DOC   \"${ARG_PACKAGE_DOC} include directory\"
)

find_library(${ARG_MODULE_NAME}_LIBRARY
    NAMES ${ARG_TARGET_NAME}
    DOC   \"${ARG_PACKAGE_DOC} static library\"
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(${ARG_MODULE_NAME}
    REQUIRED_VARS
        ${ARG_MODULE_NAME}_INCLUDE_DIR
        ${ARG_MODULE_NAME}_LIBRARY
)

if(${ARG_MODULE_NAME}_FOUND AND NOT TARGET ${ARG_NAMESPACE}::${ARG_TARGET_NAME})
    add_library(${ARG_NAMESPACE}::${ARG_TARGET_NAME} STATIC IMPORTED)
    set_target_properties(${ARG_NAMESPACE}::${ARG_TARGET_NAME} PROPERTIES
        IMPORTED_LOCATION             \"\${${ARG_MODULE_NAME}_LIBRARY}\"
        INTERFACE_INCLUDE_DIRECTORIES \"\${${ARG_MODULE_NAME}_INCLUDE_DIR}\"
    )
endif()

mark_as_advanced(
    ${ARG_MODULE_NAME}_INCLUDE_DIR
    ${ARG_MODULE_NAME}_LIBRARY
)
")
endfunction()

# Generates a FindXxxShared.cmake module for a shared library.
#
# Required arguments:
#   MODULE_NAME  — find-module name without "Find" prefix (e.g. "BehaviorTreeShared")
#   NAMESPACE    — CMake namespace for the imported target (e.g. "BehaviorTree")
#   TARGET_NAME  — imported target name without namespace (e.g. "behaviorTreeShared")
#   HEADER_NAME  — header path to locate via find_path (e.g. "behaviorTree/iNode.hpp")
#   PACKAGE_DOC  — human-readable package name for docs (e.g. "behavior-tree")
function(generate_find_shared_module)
    cmake_parse_arguments(ARG "" "MODULE_NAME;NAMESPACE;TARGET_NAME;HEADER_NAME;PACKAGE_DOC" "" ${ARGN})

    if(NOT ARG_MODULE_NAME OR NOT ARG_NAMESPACE OR NOT ARG_TARGET_NAME OR NOT ARG_HEADER_NAME OR NOT ARG_PACKAGE_DOC)
        message(FATAL_ERROR "generate_find_shared_module requires MODULE_NAME, NAMESPACE, TARGET_NAME, HEADER_NAME, and PACKAGE_DOC")
    endif()

    set(_out "${PROJECT_BINARY_DIR}/cmake/Find${ARG_MODULE_NAME}.cmake")

    file(WRITE "${_out}"
"# Find${ARG_MODULE_NAME}.cmake
# ----------------------------
# Finds the ${ARG_PACKAGE_DOC} shared library.
#
# Imported targets:
#   ${ARG_NAMESPACE}::${ARG_TARGET_NAME} - shared library
#
# Cache variables:
#   ${ARG_MODULE_NAME}_INCLUDE_DIR - directory containing ${ARG_HEADER_NAME}
#   ${ARG_MODULE_NAME}_LIBRARY     - path to lib${ARG_TARGET_NAME}.so

cmake_minimum_required(VERSION 3.25)

find_path(${ARG_MODULE_NAME}_INCLUDE_DIR
    NAMES ${ARG_HEADER_NAME}
    DOC   \"${ARG_PACKAGE_DOC} include directory\"
)

find_library(${ARG_MODULE_NAME}_LIBRARY
    NAMES ${ARG_TARGET_NAME}
    DOC   \"${ARG_PACKAGE_DOC} shared library\"
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(${ARG_MODULE_NAME}
    REQUIRED_VARS
        ${ARG_MODULE_NAME}_INCLUDE_DIR
        ${ARG_MODULE_NAME}_LIBRARY
)

if(${ARG_MODULE_NAME}_FOUND AND NOT TARGET ${ARG_NAMESPACE}::${ARG_TARGET_NAME})
    add_library(${ARG_NAMESPACE}::${ARG_TARGET_NAME} SHARED IMPORTED)
    set_target_properties(${ARG_NAMESPACE}::${ARG_TARGET_NAME} PROPERTIES
        IMPORTED_LOCATION             \"\${${ARG_MODULE_NAME}_LIBRARY}\"
        INTERFACE_INCLUDE_DIRECTORIES \"\${${ARG_MODULE_NAME}_INCLUDE_DIR}\"
    )
endif()

mark_as_advanced(
    ${ARG_MODULE_NAME}_INCLUDE_DIR
    ${ARG_MODULE_NAME}_LIBRARY
)
")
endfunction()

# Generates a FindXxxInterface.cmake module for a header-only library.
#
# Required arguments:
#   MODULE_NAME  — find-module name without "Find" prefix (e.g. "BehaviorTreeInterface")
#   NAMESPACE    — CMake namespace for the imported target (e.g. "BehaviorTree")
#   TARGET_NAME  — imported target name without namespace (e.g. "behaviorTreeInterface")
#   HEADER_NAME  — header path to locate via find_path (e.g. "behaviorTree/iNode.hpp")
#   PACKAGE_DOC  — human-readable package name for docs (e.g. "behavior-tree")
function(generate_find_interface_module)
    cmake_parse_arguments(ARG "" "MODULE_NAME;NAMESPACE;TARGET_NAME;HEADER_NAME;PACKAGE_DOC" "" ${ARGN})

    if(NOT ARG_MODULE_NAME OR NOT ARG_NAMESPACE OR NOT ARG_TARGET_NAME OR NOT ARG_HEADER_NAME OR NOT ARG_PACKAGE_DOC)
        message(FATAL_ERROR "generate_find_interface_module requires MODULE_NAME, NAMESPACE, TARGET_NAME, HEADER_NAME, and PACKAGE_DOC")
    endif()

    set(_out "${PROJECT_BINARY_DIR}/cmake/Find${ARG_MODULE_NAME}.cmake")

    file(WRITE "${_out}"
"# Find${ARG_MODULE_NAME}.cmake
# --------------------------------
# Finds the ${ARG_PACKAGE_DOC} header-only interface library.
#
# Imported targets:
#   ${ARG_NAMESPACE}::${ARG_TARGET_NAME} - interface (header-only) library
#
# Cache variables:
#   ${ARG_MODULE_NAME}_INCLUDE_DIR - directory containing ${ARG_HEADER_NAME}

cmake_minimum_required(VERSION 3.25)

find_path(${ARG_MODULE_NAME}_INCLUDE_DIR
    NAMES ${ARG_HEADER_NAME}
    DOC   \"${ARG_PACKAGE_DOC} include directory\"
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(${ARG_MODULE_NAME}
    REQUIRED_VARS ${ARG_MODULE_NAME}_INCLUDE_DIR
)

if(${ARG_MODULE_NAME}_FOUND AND NOT TARGET ${ARG_NAMESPACE}::${ARG_TARGET_NAME})
    add_library(${ARG_NAMESPACE}::${ARG_TARGET_NAME} INTERFACE IMPORTED)
    set_target_properties(${ARG_NAMESPACE}::${ARG_TARGET_NAME} PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES \"\${${ARG_MODULE_NAME}_INCLUDE_DIR}\"
    )
endif()

mark_as_advanced(${ARG_MODULE_NAME}_INCLUDE_DIR)
")
endfunction()
