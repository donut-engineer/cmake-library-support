# cmake-library-support

[![CI](https://github.com/donut-engineer/cmake-library-support/actions/workflows/ci.yml/badge.svg)](https://github.com/donut-engineer/cmake-library-support/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-github--pages-blue)](https://donut-engineer.github.io/cmake-library-support/)

Authoring a redistributable C or C++ library in CMake means stitching together coverage, versioning, install rules, packaging, and dependency fetching from scratch on every project. This repo packages that boilerplate as seven independently-includeable modules.

Every module in this repo serves that specific workflow — coverage reporting, version stamping, private dependency fetching, and install/package generation. Modules that don't serve a C or C++ library author's build and release pipeline don't belong here.

All modules work for pure-C projects (`project(... LANGUAGES C)`) as well as C++. The `coverage` and `sanitizers` modules use the C++ compiler when it's enabled and fall back to the C compiler otherwise, so a C-only project is fully supported.

## Requirements

- CMake 3.15+ (all modules)
- CMake 3.18+ (`github-release-dependency.cmake` only — uses `file(ARCHIVE_EXTRACT)`)
- For `coverage.cmake` (Linux/macOS only), one of:
  - GCC + gcovr 5+ (`pip install gcovr`)
  - Clang/AppleClang + LLVM 18 + gcovr 5+ (`pip install gcovr`; LLVM provides `llvm-cov`)

## Integration

Add to your project via FetchContent:

```cmake
include(FetchContent)
FetchContent_Declare(cmake_library_support
    GIT_REPOSITORY https://github.com/donut-engineer/cmake-library-support.git
    GIT_TAG vX.Y.Z
)
FetchContent_MakeAvailable(cmake_library_support)
# CMAKE_LIBRARY_SUPPORT_DIR and CMAKE_MODULE_PATH are now set automatically
```

For a complete consumer example that exercises every module — install rules, config templates, coverage, and CPack — see [`tests/integration/mylib/CMakeLists.txt`](tests/integration/mylib/CMakeLists.txt).

## Modules

### coverage.cmake

Code coverage with HTML reporting and 100% line coverage enforcement. Supports GCC
and Clang/AppleClang. Requires `gcovr` (`pip install gcovr`); Clang/AppleClang also
requires `llvm-cov` from LLVM 18. Linux and macOS only.

```cmake
include(coverage)
target_enable_coverage(TARGET myLib)      # apply to every target whose source you want measured
target_enable_coverage(TARGET myTests)
add_coverage_report_target(TEST_TARGET myTests)
```

Pass `EXCLUDE_REGEX` to override which paths are excluded from the report (matched against full file paths). The default excludes `googletest`, `googlemock`, `/usr/`, and any path containing a directory named `test`:

```cmake
add_coverage_report_target(
    TEST_TARGET myTests
    EXCLUDE_REGEX ".*/googletest/.*|.*/googlemock/.*|/usr/.*|.*/test/.*"
)
```

Run the `coverage` target after building:

```bash
cmake --build build --target coverage
```

The build fails if line coverage drops below 100%. The HTML report is written to `build/coverage/html/index.html`.

### sanitizers.cmake

Enables compiler/linker sanitizer flags on a target with the right syntax for
the active compiler. Validates unsupported and mutually-incompatible
combinations at configure time.

| Sanitizer  | GNU | Clang | AppleClang | MSVC |
|------------|:---:|:-----:|:----------:|:----:|
| ADDRESS    | ✓   | ✓     | ✓          | ✓    |
| UNDEFINED  | ✓   | ✓     | ✓          | ✗    |
| THREAD     | ✓   | ✓     | ✓          | ✗    |
| MEMORY     | ✗   | ✓     | ✗          | ✗    |
| LEAK       | ✓   | ✓     | ✓          | ✗    |

`ADDRESS`+`THREAD`, `ADDRESS`+`MEMORY`, and `THREAD`+`MEMORY` cannot be
combined and are configure-time errors. Any unsupported combination (e.g.
`MEMORY` on GCC, `UNDEFINED` on MSVC) is also a configure-time error.

```cmake
include(sanitizers)
target_enable_sanitizers(
    TARGET    myTests
    ADDRESS
    UNDEFINED
)
```

`-fno-omit-frame-pointer` is added automatically on GCC/Clang/AppleClang so
sanitizer reports include readable stack traces. The MSVC ASan runtime is
auto-linked, so no link options are needed there. Scope is `INTERFACE` for
interface-library targets and `PRIVATE` otherwise.

### generate-version.cmake

Git-based version stamping. On the `release` branch the version is used as-is; on any other branch the short commit hash (and `-dirty` if the working tree is modified) is appended.

> **Release branch name:** The script matches the literal string `release`. Any other branch name — including `main`, `production`, or `stable` — produces a hash-suffixed version string. Ensure your release branch is named `release`, or wrap the `add_custom_target` call to pass a different `-DSOURCE_DIR` pointing to a checkout of that branch.

Invoked via `cmake -P` as a custom target:

```cmake
add_custom_target(generate_version ALL
    COMMAND ${CMAKE_COMMAND}
        -D SOURCE_DIR=${CMAKE_SOURCE_DIR}
        -D VERSION=${PROJECT_VERSION}
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

> **Testing note:** The download, SHA256 cache-hit, and token-sanitization paths of this module require a live `GH_TOKEN` and a real private release asset, so they are not covered by the automated test suite. The argument-validation and missing-token paths are tested. The token-scrubbing logic can be reviewed in [`cmake/github-release-dependency.cmake`](cmake/github-release-dependency.cmake).

### config-template.cmake

Generates the `*-config.cmake.in` template consumed by `configure_package_config_file()`
in `install-rules.cmake`. Call this before `library_install_rules()`.

By default (no flags), the template includes all three target types. Pass `STATIC`,
`SHARED`, and/or `INTERFACE` flags to include only the relevant ones.

```cmake
include(config-template)

# All three target types (default)
generate_config_template(PACKAGE_NAME "my-library")

# Interface-only library
generate_config_template(
    PACKAGE_NAME "my-library"
    INTERFACE
)

# Static and shared, no interface
generate_config_template(
    PACKAGE_NAME "my-library"
    STATIC
    SHARED
)
```

### install-rules.cmake

Installs static, shared, and interface library targets with proper CMake export sets,
config-mode package files, and optional Doxygen documentation. `STATIC_TARGET`,
`SHARED_TARGET`, and `INTERFACE_TARGET` are all optional — provide only the ones your
library actually builds. At least one must be specified.

```cmake
include(install-rules)

# All three target types
library_install_rules(
    PACKAGE_NAME "my-library"
    NAMESPACE "MyLibrary"
    STATIC_TARGET myLibrary
    SHARED_TARGET myLibraryShared
    INTERFACE_TARGET myLibraryInterface
)

# Interface-only library
library_install_rules(
    PACKAGE_NAME "my-library"
    NAMESPACE "MyLibrary"
    INTERFACE_TARGET myLibraryInterface
)
```

### package-rules.cmake

Configures CPack to produce a single archive containing all install components (Static, Shared, Interface, Docs). The format is `.tar.gz` on Linux/macOS and `.zip` on Windows.

```cmake
include(package-rules)
library_package_rules(
    PACKAGE_NAME "my-library"
    DESCRIPTION "My Library C++ Library"
)
```

## License

MIT — see [LICENSE](LICENSE).
