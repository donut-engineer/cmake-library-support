# cmake-utilities

Shared CMake modules for C++ library projects. Provides coverage reporting, version generation, GitHub release dependency fetching, and parameterized install/package/find-module generation.

## Authentication

This is a private repository. To allow CMake's FetchContent (or any `git clone` over HTTPS) to authenticate, set a `GH_TOKEN` environment variable and configure Git to use a credential helper.

### 1. Set `GH_TOKEN`

```bash
export GH_TOKEN="ghp_your_token_here"
```

### 2. Configure Git credential helper

```bash
git config --global credential.helper '!f() { echo "username=x-access-token"; echo "password=${GH_TOKEN}"; }; f'
```

This keeps the token out of URLs entirely. If a clone fails, error messages will only show `https://github.com/...` with no embedded secret — safe for CI logs and terminal output.

## Integration

Add to your project via FetchContent:

```cmake
include(FetchContent)
FetchContent_Declare(cmake_utilities
    GIT_REPOSITORY https://github.com/donut-engineer/cmake-utilities.git
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

Fetches dependencies from private GitHub release assets using `GH_TOKEN`.

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
