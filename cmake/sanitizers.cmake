# Enables compiler/linker sanitizer flags on the given target. Supports
# AddressSanitizer (ADDRESS), UndefinedBehaviorSanitizer (UNDEFINED),
# ThreadSanitizer (THREAD), MemorySanitizer (MEMORY) and LeakSanitizer (LEAK).
# At least one sanitizer flag must be supplied.
#
# Required argument:
#   TARGET     — CMake target the flags should be applied to. PRIVATE on
#                concrete targets, INTERFACE on interface libraries.
#
# Optional flags (at least one required):
#   ADDRESS    — -fsanitize=address (GCC/Clang/MSVC)
#   UNDEFINED  — -fsanitize=undefined (GCC/Clang)
#   THREAD     — -fsanitize=thread (GCC/Clang)
#   MEMORY     — -fsanitize=memory (Clang only; not AppleClang)
#   LEAK       — -fsanitize=leak (GCC/Clang)
#
# Errors at configure time on:
#   - unsupported compiler / sanitizer combinations (e.g. MEMORY on GCC,
#     anything-but-ADDRESS on MSVC)
#   - mutually-incompatible combinations (ADDRESS+THREAD, ADDRESS+MEMORY,
#     THREAD+MEMORY)
function(target_enable_sanitizers)
    cmake_parse_arguments(ARG "ADDRESS;UNDEFINED;THREAD;MEMORY;LEAK" "TARGET" "" ${ARGN})

    if(NOT ARG_TARGET)
        message(FATAL_ERROR "target_enable_sanitizers: TARGET is required")
    endif()

    set(_active "")
    foreach(_san ADDRESS UNDEFINED THREAD MEMORY LEAK)
        if(ARG_${_san})
            string(TOLOWER "${_san}" _name)
            list(APPEND _active "${_name}")
        endif()
    endforeach()

    if(NOT _active)
        message(FATAL_ERROR "target_enable_sanitizers: at least one sanitizer flag (ADDRESS, UNDEFINED, THREAD, MEMORY, LEAK) is required")
    endif()

    foreach(_pair "address;thread" "address;memory" "thread;memory")
        list(GET _pair 0 _a)
        list(GET _pair 1 _b)
        if("${_a}" IN_LIST _active AND "${_b}" IN_LIST _active)
            message(FATAL_ERROR "target_enable_sanitizers: '${_a}' and '${_b}' sanitizers cannot be combined")
        endif()
    endforeach()

    get_target_property(_type ${ARG_TARGET} TYPE)
    if(_type STREQUAL "INTERFACE_LIBRARY")
        set(_scope INTERFACE)
    else()
        set(_scope PRIVATE)
    endif()

    list(JOIN _active "," _list)
    set(_compile_opts "")
    set(_link_opts "")

    # Prefer the C++ compiler ID; fall back to C so C-only projects work too.
    if(CMAKE_CXX_COMPILER_ID)
        set(_compiler_id "${CMAKE_CXX_COMPILER_ID}")
    else()
        set(_compiler_id "${CMAKE_C_COMPILER_ID}")
    endif()

    if(_compiler_id STREQUAL "GNU")
        if("memory" IN_LIST _active)
            message(FATAL_ERROR "target_enable_sanitizers: MemorySanitizer is not supported by GCC; use Clang")
        endif()
        list(APPEND _compile_opts "-fsanitize=${_list}" "-fno-omit-frame-pointer")
        list(APPEND _link_opts    "-fsanitize=${_list}")

    elseif(_compiler_id MATCHES "^(Clang|AppleClang)$")
        if(_compiler_id STREQUAL "AppleClang" AND "memory" IN_LIST _active)
            message(FATAL_ERROR "target_enable_sanitizers: MemorySanitizer is not reliably supported on AppleClang/macOS; use upstream Clang on Linux")
        endif()
        list(APPEND _compile_opts "-fsanitize=${_list}" "-fno-omit-frame-pointer")
        list(APPEND _link_opts    "-fsanitize=${_list}")

    elseif(_compiler_id STREQUAL "MSVC")
        foreach(_s undefined thread memory leak)
            if("${_s}" IN_LIST _active)
                message(FATAL_ERROR "target_enable_sanitizers: '${_s}' sanitizer is not supported by MSVC; only ADDRESS is available")
            endif()
        endforeach()
        list(APPEND _compile_opts "/fsanitize=address")
        # MSVC auto-links the ASan runtime; no link options needed.

    else()
        message(FATAL_ERROR "target_enable_sanitizers: unsupported compiler '${_compiler_id}' (expected GNU, Clang, AppleClang, or MSVC)")
    endif()

    target_compile_options(${ARG_TARGET} ${_scope} ${_compile_opts})
    if(_link_opts)
        target_link_options(${ARG_TARGET} ${_scope} ${_link_opts})
    endif()
endfunction()
