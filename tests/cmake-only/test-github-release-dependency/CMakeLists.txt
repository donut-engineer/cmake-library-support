cmake_minimum_required(VERSION 3.18)
project(test-github-release-dependency NONE)

list(APPEND CMAKE_MODULE_PATH "${MODULES_DIR}")
include(cmake-library-support)
include(github-release-dependency)

# ---------------------------------------------------------------------------
# Test: missing required arguments produces FATAL_ERROR
# ---------------------------------------------------------------------------
# Call with no arguments — cmake_parse_arguments sets all to empty, so the
# NOT ARG_NAME guard triggers.
if(TEST_MISSING_ARGS)
    github_release_dependency()
endif()

# ---------------------------------------------------------------------------
# Test: missing GH_TOKEN produces FATAL_ERROR
# ---------------------------------------------------------------------------
# Call with all required args but no GH_TOKEN in the environment.
# The function checks for GH_TOKEN before attempting a download.
if(TEST_MISSING_TOKEN)
    github_release_dependency(
        NAME            dummy
        ASSET_URL       "https://example.com/dummy"
        SHA256          "0000000000000000000000000000000000000000000000000000000000000000"
        PACKAGE_NAME    "dummy-package"
        EXTENSION       ".tar.gz"
    )
endif()
