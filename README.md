# cmake-library-support

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

CMake modules for authoring and distributing C++ libraries. Every module in this repo serves that specific workflow — coverage reporting, version stamping, private dependency fetching, and install/package/find-module generation. Modules that don't serve a C++ library author's build and release pipeline don't belong here.

## Requirements

- CMake 3.14+
- Clang + LLVM toolchain (for `coverage.cmake`, Linux/macOS only)

## Integration

Add to your project via FetchContent:

```cmake
include(FetchContent)
FetchContent_Declare(cmake_library_support
    GIT_REPOSITORY https://github.com/tcarter690/cmake-library-support.git
    GIT_TAG v1.0.0
)
FetchContent_MakeAvailable(cmake_library_support)
include(${cmake_library_support_SOURCE_DIR}/cmake/cmake-library-support.cmake)
```

## Modules

### coverage.cmake

Clang source-based code coverage with HTML reporting and 100% line coverage enforcement.
Requires `llvm-profdata` and `llvm-cov` (LLVM 18 preferred). Linux and macOS only.

```cmake
include(coverage)
target_enable_coverage(myTests)
add_coverage_report_target(TEST_TARGET myTests)
```

Run the `coverage` target after building:

```bash
cmake --build build --target coverage
```

The build fails if line coverage drops below 100%. The HTML report is written to `build/coverage/html/index.html`.

### generate-version.cmake

Git-based version stamping. On the `release` branch the version is used as-is; on any other branch the short commit hash (and `-dirty` if the working tree is modified) is appended.

Invoked via `cmake -P` as a custom target:

```cmake
add_custom_target(generate_version ALL
    COMMAND ${CMAKE_COMMAND}
        -D SOURCE_DIR=${CMAKE_SOURCE_DIR}
        -D VERSION=${PROJECT_VERSION}
        -D VERSION_MAJOR=${PROJECT_VERSION_MAJOR}
        -D VERSION_MINOR=${PROJECT_VERSION_MINOR}
        -D VERSION_PATCH=${PROJECT_VERSION_PATCH}
        -D TEMPLATE=${CMAKE_SOURCE_DIR}/include/myLib/version.hpp.in
        -D OUTPUT=${CMAKE_BINARY_DIR}/include/myLib/version.hpp
        -P ${CMAKE_LIBRARY_SUPPORT_DIR}/generate-version.cmake
    COMMENT "Generating version header"
)
```

The template file uses `@VERSION_FULL@` as the substitution variable.

### github-release-dependency.cmake

Fetches a dependency from a private GitHub release asset using `GH_TOKEN`. If a download
fails, the error log is sanitized so the token is replaced with `***` — your PAT is never
exposed in build output, even on failure. The archive is cached and only re-downloaded when
the SHA256 changes.

#### Setup

Set a GitHub personal access token with `repo` scope:

```bash
export GH_TOKEN="ghp_your_token_here"
```

#### Usage

```cmake
include(github-release-dependency)
github_release_dependency(
    NAME behaviorTree
    ASSET_URL "https://api.github.com/repos/owner/repo/releases/assets/12345"
    SHA256 "abc123..."
    PACKAGE_NAME "behavior-tree"
    EXTENSION ".tar.gz"
)
```

#### Finding a release asset ID

The `ASSET_URL` requires the numeric asset ID. Use the `gh` CLI to look it up:

```bash
# List all assets for a release tagged "v1.0.0"
gh release view v1.0.0 --repo owner/repo --json assets --jq '.assets[] | {name, id, url}'
```

Example output:

```json
{
  "name": "behavior-tree-1.0.0-Linux-x86_64.tar.gz",
  "id": 12345,
  "url": "https://api.github.com/repos/owner/repo/releases/assets/12345"
}
```

If you only need the asset ID for a specific file:

```bash
gh release view v1.0.0 --repo owner/repo --json assets \
  --jq '.assets[] | select(.name == "behavior-tree-1.0.0-Linux-x86_64.tar.gz") | .id'
```

Use the `url` value (or construct it from the `id`) as the `ASSET_URL` parameter.

### find-modules.cmake

Generates a `Find<Name>.cmake` module at configure time for downstream module-mode
`find_package()`. The generated module creates separate `SHARED` and `STATIC` imported
targets as well as a selector interface target controlled by a `<Name>_LIBRARY_TYPE`
cache variable.

```cmake
include(find-modules)
generate_find_module(
    MODULE_NAME "MyLibrary"
    NAMESPACE "MyLibrary"
    TARGET_NAME "myLibrary"
    HEADER_NAME "myLibrary/myLibrary.hpp"   # optional
    PACKAGE_DOC "my-library"
)
```

`HEADER_NAME` is optional. When omitted, header discovery is skipped and only the
libraries are searched for.

### config-template.cmake

Generates the `*-config.cmake.in` template consumed by `configure_package_config_file()`
in `install-rules.cmake`. Call this before `library_install_rules()`.

```cmake
include(config-template)
generate_config_template(PACKAGE_NAME "my-library")
```

### install-rules.cmake

Installs static, shared, and interface library targets with proper CMake export sets,
config-mode package files, find modules, and optional Doxygen documentation.

```cmake
include(install-rules)
library_install_rules(
    PACKAGE_NAME "my-library"
    NAMESPACE "MyLibrary"
    STATIC_TARGET myLibrary
    SHARED_TARGET myLibraryShared
    INTERFACE_TARGET myLibraryInterface
)
```

### package-rules.cmake

Configures CPack to produce a single `TGZ` (Linux) or `ZIP` (Windows) archive containing
all install components (Static, Shared, Interface, Docs).

```cmake
include(package-rules)
library_package_rules(
    PACKAGE_NAME "my-library"
    DESCRIPTION "My Library C++ Library"
)
```

## License

MIT — see [LICENSE](LICENSE).
