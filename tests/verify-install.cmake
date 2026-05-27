# Verifies that cmake --install produced the expected directory layout.
# Required -D argument:
#   INSTALL_PREFIX — the prefix passed to cmake --install

if(NOT INSTALL_PREFIX)
    message(FATAL_ERROR "verify-install.cmake: INSTALL_PREFIX is required")
endif()

set(_expected_files
    "${INSTALL_PREFIX}/lib/cmake/mylib/mylib-config.cmake"
    "${INSTALL_PREFIX}/lib/cmake/mylib/mylib-config-version.cmake"
    "${INSTALL_PREFIX}/include/mylib/mylib.h"
)

foreach(_f ${_expected_files})
    if(NOT EXISTS "${_f}")
        message(FATAL_ERROR "Expected installed file not found: ${_f}")
    endif()
endforeach()
