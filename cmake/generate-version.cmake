execute_process(
    COMMAND git rev-parse --abbrev-ref HEAD
    OUTPUT_VARIABLE GIT_BRANCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY "${SOURCE_DIR}"
    ERROR_QUIET
)

if(GIT_BRANCH STREQUAL "release")
    set(VERSION_FULL "${VERSION}")
else()
    execute_process(
        COMMAND git rev-parse --short HEAD
        OUTPUT_VARIABLE GIT_COMMIT_ID
        OUTPUT_STRIP_TRAILING_WHITESPACE
        WORKING_DIRECTORY "${SOURCE_DIR}"
        ERROR_QUIET
    )

    execute_process(
        COMMAND git status --porcelain
        OUTPUT_VARIABLE GIT_STATUS
        OUTPUT_STRIP_TRAILING_WHITESPACE
        WORKING_DIRECTORY "${SOURCE_DIR}"
        ERROR_QUIET
    )

    if(NOT GIT_COMMIT_ID)
        set(GIT_COMMIT_ID "unknown")
    endif()

    if(GIT_STATUS STREQUAL "")
        set(VERSION_FULL "${VERSION}-${GIT_COMMIT_ID}")
    else()
        set(VERSION_FULL "${VERSION}-${GIT_COMMIT_ID}-dirty")
    endif()
endif()

configure_file("${TEMPLATE}" "${OUTPUT}" @ONLY)
