# Generates a <package>-config.cmake.in file at configure time.
# The generated file is used by configure_package_config_file() in
# install-rules.cmake to produce the installed config file.
#
# Required arguments:
#   PACKAGE_NAME — kebab-case package name (e.g. "behavior-tree")
#
# Output:
#   ${PROJECT_BINARY_DIR}/cmake/${PACKAGE_NAME}-config.cmake.in
function(generate_config_template)
    cmake_parse_arguments(ARG "" "PACKAGE_NAME" "" ${ARGN})

    if(NOT ARG_PACKAGE_NAME)
        message(FATAL_ERROR "generate_config_template requires PACKAGE_NAME")
    endif()

    set(_pkg "${ARG_PACKAGE_NAME}")
    set(_out "${PROJECT_BINARY_DIR}/cmake/${_pkg}-config.cmake.in")

    file(WRITE "${_out}"
"@PACKAGE_INIT@

include(\"\${CMAKE_CURRENT_LIST_DIR}/${_pkg}-static-targets.cmake\" OPTIONAL)
include(\"\${CMAKE_CURRENT_LIST_DIR}/${_pkg}-shared-targets.cmake\" OPTIONAL)
include(\"\${CMAKE_CURRENT_LIST_DIR}/${_pkg}-interface-targets.cmake\" OPTIONAL)

check_required_components(${_pkg})
")
endfunction()
