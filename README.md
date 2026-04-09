# cmake-utilities

Shared CMake modules for C++ library projects. Provides coverage reporting, version generation, GitHub release dependency fetching, and parameterized install/package/find-module generation.

## Authentication

This is a private repository. To allow CMake's FetchContent (or any `git clone` over HTTPS) to authenticate, set a `GH_TOKEN` environment variable and configure Git to rewrite GitHub URLs with the token.

### 1. Set `GH_TOKEN`

```bash
export GH_TOKEN="ghp_your_token_here"
```

### 2. Configure Git URL rewriting

```bash
git config --global url."https://x-access-token:${GH_TOKEN}@github.com/".insteadOf "https://github.com/"
```

This rewrites all `https://github.com/` URLs to include authentication automatically, so FetchContent and `git clone` work without any changes to the repository URLs themselves.

## Integration

Add to your project via FetchContent:

```cmake
include(FetchContent)
FetchContent_Declare(cmake_utilities
    GIT_REPOSITORY https://github.com/tcarter690/cmake-utilities.git
    GIT_TAG main
)
FetchContent_MakeAvailable(cmake_utilities)
include(${cmake_utilities_SOURCE_DIR}/cmake/cmake-utilities.cmake)
```

## Modules

### coverage.cmake

Clang source-based code coverage with HTML reporting and 100% line coverage enforcement.

```cmake
include(coverage)
target_enable_coverage(myTests)
add_coverage_report_target(TEST_TARGET myTests)
```

### generate-version.cmake

Git-based version stamping script. Invoked via `cmake -P`:

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
        -P ${CMAKE_UTILITIES_DIR}/generate-version.cmake
    COMMENT "Generating version header"
)
```

### github-release-dependency.cmake

Fetches dependencies from private GitHub release assets using `GH_TOKEN`. If a download fails, the error log is sanitized so that the token is replaced with `***` — your PAT is never exposed in build output, even on failure.

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

Generates `Find*.cmake` modules at configure time for downstream module-mode `find_package()`.

```cmake
include(find-modules)
generate_find_static_module(
    MODULE_NAME "MyLibraryStatic"
    NAMESPACE "MyLibrary"
    TARGET_NAME "myLibrary"
    HEADER_NAME "myLibrary/myLibrary.hpp"
    PACKAGE_DOC "my-library"
)
generate_find_shared_module(
    MODULE_NAME "MyLibraryShared"
    NAMESPACE "MyLibrary"
    TARGET_NAME "myLibraryShared"
    HEADER_NAME "myLibrary/myLibrary.hpp"
    PACKAGE_DOC "my-library"
)
generate_find_interface_module(
    MODULE_NAME "MyLibraryInterface"
    NAMESPACE "MyLibrary"
    TARGET_NAME "myLibraryInterface"
    HEADER_NAME "myLibrary/myLibrary.hpp"
    PACKAGE_DOC "my-library"
)
```

### config-template.cmake

Generates the `*-config.cmake.in` template for `configure_package_config_file()`.

```cmake
include(config-template)
generate_config_template(PACKAGE_NAME "my-library")
```

### install-rules.cmake

Installs static, shared, and interface library targets with proper export sets, config files, find modules, and documentation.

```cmake
include(install-rules)
library_install_rules(
    PACKAGE_NAME "my-library"
    NAMESPACE "my-library"
    STATIC_TARGET myLibrary
    SHARED_TARGET myLibraryShared
    INTERFACE_TARGET myLibraryInterface
)
```

### package-rules.cmake

Configures CPack for component-based packaging (Static, Shared, Interface).

```cmake
include(package-rules)
library_package_rules(
    PACKAGE_NAME "my-library"
    DESCRIPTION "My Library C++ Library"
)
```
