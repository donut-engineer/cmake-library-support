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

    # 1. Force everything into one single archive
    set(CPACK_MONOLITHIC_INSTALL ON)
    set(CPACK_ARCHIVE_COMPONENT_INSTALL OFF)

    # Include architecture in package filename
    set(CPACK_SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")

    # TGZ for Linux, ZIP for Windows
    set(CPACK_GENERATOR "TGZ;ZIP")

    # Optional: If you still want the UI (like a Windows NSIS installer) 
    # to show checkboxes, you can keep these, but for ZIP/TGZ they are ignored 
    # now that component install is OFF.
    set(CPACK_COMPONENTS_ALL Static Shared Interface Docs)

    include(CPack)
endfunction()
