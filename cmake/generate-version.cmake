execute_process(
    COMMAND git rev-parse --abbrev-ref HEAD
    OUTPUT_VARIABLE GIT_BRANCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY "${SOURCE_DIR}"
    RESULT_VARIABLE _git_result
    ERROR_QUIET
)

if(NOT _git_result EQUAL 0)
    message(WARNING "generate-version: git is unavailable or SOURCE_DIR is not a git repo — using '${VERSION}' as-is")
    set(VERSION_FULL "${VERSION}")
    configure_file("${TEMPLATE}" "${OUTPUT}" @ONLY)
    return()
endif()

# Detached HEAD produces "(HEAD detached at <hash>)" — treat as a non-release branch
if(GIT_BRANCH MATCHES "^HEAD" OR GIT_BRANCH STREQUAL "")
    set(GIT_BRANCH "__detached__")
endif()

if(GIT_BRANCH STREQUAL "release")
    set(VERSION_FULL "${VERSION}")
else()
    execute_process(
        COMMAND git rev-parse --short HEAD
        OUTPUT_VARIABLE GIT_COMMIT_ID
        OUTPUT_STRIP_TRAILING_WHITESPACE
        WORKING_DIRECTORY "${SOURCE_DIR}"
        RESULT_VARIABLE _git_result
        ERROR_QUIET
    )
    if(NOT _git_result EQUAL 0 OR NOT GIT_COMMIT_ID)
        set(GIT_COMMIT_ID "unknown")
    endif()

    execute_process(
        COMMAND git status --porcelain
        OUTPUT_VARIABLE GIT_STATUS
        OUTPUT_STRIP_TRAILING_WHITESPACE
        WORKING_DIRECTORY "${SOURCE_DIR}"
        RESULT_VARIABLE _git_result
        ERROR_QUIET
    )

    if(_git_result EQUAL 0 AND NOT GIT_STATUS STREQUAL "")
        set(VERSION_FULL "${VERSION}-${GIT_COMMIT_ID}-dirty")
    else()
        set(VERSION_FULL "${VERSION}-${GIT_COMMIT_ID}")
    endif()
endif()

configure_file("${TEMPLATE}" "${OUTPUT}" @ONLY)
