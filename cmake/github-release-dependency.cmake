include(FetchContent)

# Fetches a dependency from a private GitHub release asset, keeping GH_TOKEN
# out of error output.
#
# Usage:
#   github_release_dependency(
#       NAME behaviorTree
#       ASSET_URL "https://api.github.com/repos/owner/repo/releases/assets/12345"
#       SHA256 "abc123..."
#       PACKAGE_NAME "behavior-tree"
#       EXTENSION ".tar.gz"
#   )
function(github_release_dependency)
    cmake_parse_arguments(ARG "" "NAME;ASSET_URL;SHA256;PACKAGE_NAME;EXTENSION" "" ${ARGN})

    if(NOT ARG_NAME OR NOT ARG_ASSET_URL OR NOT ARG_SHA256 OR NOT ARG_PACKAGE_NAME OR NOT ARG_EXTENSION)
        message(FATAL_ERROR "github_release_dependency requires NAME, ASSET_URL, SHA256, PACKAGE_NAME, and EXTENSION")
    endif()

    if(NOT DEFINED ENV{GH_TOKEN})
        message(FATAL_ERROR "GH_TOKEN environment variable is not set")
    endif()

    set(ARCHIVE "${FETCHCONTENT_BASE_DIR}/${ARG_NAME}${ARG_EXTENSION}")

    set(NEEDS_DOWNLOAD TRUE)
    if(EXISTS "${ARCHIVE}")
        file(SHA256 "${ARCHIVE}" EXISTING_SHA256)
        if(EXISTING_SHA256 STREQUAL ARG_SHA256)
            set(NEEDS_DOWNLOAD FALSE)
        endif()
    endif()

    if(NEEDS_DOWNLOAD)
        file(DOWNLOAD "${ARG_ASSET_URL}" "${ARCHIVE}"
            HTTPHEADER "Authorization: token $ENV{GH_TOKEN}"
            HTTPHEADER "Accept: application/octet-stream"
            STATUS DOWNLOAD_STATUS
            LOG DOWNLOAD_LOG
        )
        list(GET DOWNLOAD_STATUS 0 STATUS_CODE)
        if(NOT STATUS_CODE EQUAL 0)
            string(REPLACE "$ENV{GH_TOKEN}" "***" SAFE_LOG "${DOWNLOAD_LOG}")
            file(REMOVE "${ARCHIVE}")
            message(FATAL_ERROR "${ARG_NAME} download failed:\n${SAFE_LOG}")
        endif()
    endif()

    FetchContent_Declare(
        ${ARG_NAME}
        URL "file://${ARCHIVE}"
        URL_HASH SHA256=${ARG_SHA256}
        DOWNLOAD_NO_PROGRESS ON
    )
    FetchContent_Populate(${ARG_NAME})

    string(TOLOWER "${ARG_NAME}" LOWER_NAME)
    list(APPEND CMAKE_PREFIX_PATH "${${LOWER_NAME}_SOURCE_DIR}")
    set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" PARENT_SCOPE)
    find_package(${ARG_PACKAGE_NAME} REQUIRED)
endfunction()
