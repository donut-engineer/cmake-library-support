# Configures CPack for a library with Static, Shared, and Interface components.
#
# Required arguments:
#   PACKAGE_NAME  — kebab-case package name (e.g. "behavior-tree")
#   DESCRIPTION   — one-line package description (e.g. "Behavior Tree C++ Library")
function(library_package_rules)
    cmake_parse_arguments(ARG "" "PACKAGE_NAME;DESCRIPTION" "" ${ARGN})

    if(NOT ARG_PACKAGE_NAME OR NOT ARG_DESCRIPTION)
        message(FATAL_ERROR "library_package_rules requires PACKAGE_NAME and DESCRIPTION")
    endif()

    set(CPACK_PACKAGE_NAME "${ARG_PACKAGE_NAME}")
    set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${ARG_DESCRIPTION}")

    # TGZ for Linux, ZIP for Windows
    set(CPACK_GENERATOR "TGZ;ZIP")

    # One archive per component
    set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
    set(CPACK_COMPONENTS_GROUPING ONE_PER_GROUP)

    set(CPACK_COMPONENT_STATIC_DISPLAY_NAME "Static Library")
    set(CPACK_COMPONENT_STATIC_DESCRIPTION
        "Static library, public headers, and CMake config")

    set(CPACK_COMPONENT_SHARED_DISPLAY_NAME "Shared Library")
    set(CPACK_COMPONENT_SHARED_DESCRIPTION
        "Shared library, public headers, and CMake config")

    set(CPACK_COMPONENT_INTERFACE_DISPLAY_NAME "Interface (Header-Only) Library")
    set(CPACK_COMPONENT_INTERFACE_DESCRIPTION
        "Public headers and CMake config for header-only use")

    set(CPACK_COMPONENT_DOCS_DISPLAY_NAME "Documentation")
    set(CPACK_COMPONENT_DOCS_DESCRIPTION
        "Doxygen HTML API documentation")

    set(CPACK_COMPONENTS_ALL Static Shared Interface)

    include(CPack)
endfunction()
