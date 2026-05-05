# Generates a <package>-config.cmake.in file at configure time.
# The generated file is used by configure_package_config_file() in
# install-rules.cmake to produce the installed config file.
#
# Required arguments:
#   PACKAGE_NAME — kebab-case package name (e.g. "behavior-tree")
#
# Optional arguments:
#   STATIC    — include the static targets file
#   SHARED    — include the shared targets file
#   INTERFACE — include the interface targets file
#
# If none of STATIC, SHARED, or INTERFACE are specified, all three are included.
#
# Output:
#   ${PROJECT_BINARY_DIR}/cmake/${PACKAGE_NAME}-config.cmake.in
function(generate_config_template)
    cmake_parse_arguments(ARG "STATIC;SHARED;INTERFACE" "PACKAGE_NAME" "" ${ARGN})

    if(NOT ARG_PACKAGE_NAME)
        message(FATAL_ERROR "generate_config_template requires PACKAGE_NAME")
    endif()

    # Default to all three if none specified (backward compatibility)
    if(NOT ARG_STATIC AND NOT ARG_SHARED AND NOT ARG_INTERFACE)
        set(ARG_STATIC TRUE)
        set(ARG_SHARED TRUE)
        set(ARG_INTERFACE TRUE)
    endif()

    set(_pkg "${ARG_PACKAGE_NAME}")
    set(_out "${PROJECT_BINARY_DIR}/cmake/${_pkg}-config.cmake.in")

    set(_include_lines "")
    if(ARG_STATIC)
        list(APPEND _include_lines "include(\"\${CMAKE_CURRENT_LIST_DIR}/${_pkg}-static-targets.cmake\" OPTIONAL)")
    endif()
    if(ARG_SHARED)
        list(APPEND _include_lines "include(\"\${CMAKE_CURRENT_LIST_DIR}/${_pkg}-shared-targets.cmake\" OPTIONAL)")
    endif()
    if(ARG_INTERFACE)
        list(APPEND _include_lines "include(\"\${CMAKE_CURRENT_LIST_DIR}/${_pkg}-interface-targets.cmake\" OPTIONAL)")
    endif()

    list(JOIN _include_lines "\n" _includes_block)

    file(WRITE "${_out}"
"@PACKAGE_INIT@

${_includes_block}

check_required_components(${_pkg})
")
endfunction()
