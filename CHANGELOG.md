# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.6.0] - 2026-06-18

### Added
- `coverage.cmake`: `add_coverage_report_target` accepts an optional `SEARCH_DIR`
  argument that sets the path gcovr searches for `.gcda` files. Defaults to
  `CMAKE_BINARY_DIR` for backwards compatibility. Set to a library's own binary
  directory when multiple libraries share a build tree to avoid cross-contamination
  of coverage data.

## [2.5.0] - 2026-05-28

### Changed
- `coverage.cmake`: the coverage target now runs ctest with `WORKING_DIRECTORY` set
  to `CMAKE_CURRENT_BINARY_DIR` (the calling library's binary directory at configure
  time) instead of `CMAKE_BINARY_DIR`. CTest reads `CTestTestfile.cmake` from its
  working directory, so this automatically scopes test execution to the tests
  registered under the calling library without requiring `--test-dir` or a CMake
  version bump.

### Fixed
- `coverage.cmake`: `add_coverage_report_target` now emits `FATAL_ERROR` for
  unrecognized keyword arguments. Previously `cmake_parse_arguments` silently
  discarded unknown keywords, masking typos in call sites.

## [2.4.0] - 2026-05-27

### Added
- `coverage.cmake`: `add_coverage_report_target` accepts an optional `NAME`
  argument (default `coverage`) that names the generated custom target and its
  `build/<NAME>/html` report directory, so a project can create more than one
  coverage report target. The previous hardcoded `coverage` target name is
  preserved as the default.
- C library support. The `integration/mylib` consumer is now configured twice —
  once as a C++ project (`CONSUMER_LANG=CXX`) and once as a C project
  (`CONSUMER_LANG=C`) — from a single shared library source, on both Clang
  (`integration-c-*`) and GCC (`integration-gcc-c-*`). New cmake-only cases
  (`coverage-c-fallback`, `sanitizers-c-gnu-address-undefined`,
  `sanitizers-c-clang-address-undefined`) exercise the C compiler-id fallback.

### Changed
- `coverage.cmake` and `sanitizers.cmake`: the compiler-detection logic now
  prefers `CMAKE_CXX_COMPILER_ID` and falls back to `CMAKE_C_COMPILER_ID`, so
  C-only projects (`project(... LANGUAGES C)`) are supported. Previously the
  empty C++ compiler id tripped the unsupported-compiler `FATAL_ERROR`.
- `tests/integration/mylib`: the consumer's library source is now plain C
  (`src/mylib.c`, `include/mylib/mylib.h`) shared between the C and C++ builds,
  replacing the C++-only `mylib.cpp`/`mylib.hpp`.

## [2.3.0] - 2026-05-25

### Added
- GitHub Pages landing page (`index.html`) with feature overview, quick-start snippet, and automated deployment via `.github/workflows/pages.yml` on pushes to `release`.

## [2.2.0] - 2026-05-25

### Added
- `sanitizers.cmake` module with `target_enable_sanitizers()` for enabling AddressSanitizer, UndefinedBehaviorSanitizer, ThreadSanitizer, MemorySanitizer, and LeakSanitizer with compiler-aware flags (GCC, Clang, AppleClang, MSVC). Validates unsupported and mutually-incompatible combinations at configure time.
- `coverage.cmake`: GCC support. Both `target_enable_coverage` and
  `add_coverage_report_target` now support `GNU` in addition to `Clang` and
  `AppleClang`. A new `integration-gcc-*` fixture chain in the test suite exercises
  the GCC path on CI.

### Changed
- `coverage.cmake`: switched reporting backend from `llvm-profdata`/`llvm-cov` to
  `gcovr` (BSD-3-Clause, `pip install gcovr`). Both GCC and Clang/AppleClang now use
  `gcovr`; Clang/AppleClang still requires `llvm-cov` as the gcov backend
  (`--gcov-executable`). The `llvm-profdata` merge step and bash glob/AWK pipeline
  are removed.
- `coverage.cmake`: `target_enable_coverage` now uses `--coverage` for all supported
  compilers (previously `-fprofile-instr-generate -fcoverage-mapping` for Clang).
- `coverage.cmake`: `target_enable_coverage` and `add_coverage_report_target` now emit
  `FATAL_ERROR` for unsupported compilers instead of silently applying incorrect flags.
- `coverage.cmake`: default `EXCLUDE_REGEX` changed from `.*/tests/.*` to `.*/test/.*`
  (singular) so that library source files under a `tests/` project root are not
  inadvertently excluded from coverage measurement.
- CI: Clang integration job (`integration-tests-clang`) now installs `gcovr` in
  addition to LLVM 18. A new `integration-tests-gcc` job runs in parallel.

## [2.1.3] - 2026-05-09

### Fixed
- `install-rules.cmake`: exclude `*.in` template files from the public header install so they are never packaged alongside compiled headers.

## [2.1.2] - 2026-05-07

### Fixed
- Root `CMakeLists.txt`: propagate `CMAKE_MODULE_PATH` to the consumer's scope via
  `PARENT_SCOPE` so that `FetchContent_MakeAvailable(cmake_library_support)` correctly
  makes the cmake/ directory discoverable without any additional consumer code.

## [2.1.1] - 2026-05-07

### Added
- Root `CMakeLists.txt` so `FetchContent_MakeAvailable(cmake_library_support)` automatically
  sets `CMAKE_LIBRARY_SUPPORT_DIR` and `CMAKE_MODULE_PATH`. No extra `include()` call needed.

### Fixed
- `github-release-dependency.cmake`: added `FETCHCONTENT_BASE_DIR` fallback to `${CMAKE_BINARY_DIR}/_deps` so the module works when the consumer has not called `include(FetchContent)` beforehand.
- `github-release-dependency.cmake`: archive is now re-extracted only when the SHA256 changes (stamp file), restoring the caching behaviour that `FetchContent_Populate` provided before it was replaced with `file(ARCHIVE_EXTRACT)`.

### Removed
- `cmake/cmake-library-support.cmake` — its logic now lives in the root `CMakeLists.txt`.
- `test-cmake-library-support` cmake-only test (tested the deleted entry-point file).

## [2.1.0] - 2026-05-06

### Added
- CI status badge and a one-paragraph project rationale in `README.md`.
- Pointer from `README.md` to `tests/integration/mylib/` as a complete consumer example.
- `.github/ISSUE_TEMPLATE/bug_report.md` and `.github/PULL_REQUEST_TEMPLATE.md`.
- `SECURITY.md` describing how to report vulnerabilities.
- *Releasing* section in `CONTRIBUTING.md` documenting the `develop` → `release` → annotated-tag flow.
- `add_coverage_report_target()` accepts an optional `EXCLUDE_REGEX` argument to override the default file-path exclusion pattern.
- `README.md` documents the `release` branch name constraint in `generate-version.cmake`.
- `README.md` documents the testing boundary for `github-release-dependency.cmake`.
- Pure-CMake tests for `package-rules.cmake` (CPack config generation) and `github-release-dependency.cmake` (arg-validation, missing-token).
- Release-branch code path in `generate-version.cmake` is now covered by the test suite.
- Integration test chain now includes `cmake --install` and artifact-presence verification.
- Windows added to the pure-CMake CI test matrix.

### Changed
- `CONTRIBUTING.md` *Testing* section corrected — the repo has had an automated test suite (pure-CMake + integration) since the CI workflow landed.
- `README.md` *Requirements* now pins LLVM 18 (with note that older versions may work) and lists the per-module CMake minimum for `github-release-dependency.cmake` (3.18+).
- Bumped `cmake_minimum_required` from 3.14 to 3.15 in `tests/CMakeLists.txt` and the three `tests/cmake-only/*/CMakeLists.txt` files to match the v2.0.0 floor enforced by `cmake-library-support.cmake`.
- `package-rules.cmake` now produces `.tar.gz` on Linux/macOS and `.zip` on Windows (previously generated both formats on all platforms).
- `CONTRIBUTING.md` notes the STATIC/SHARED pure-CMake test coverage boundary.

### Fixed
- `cmake-library-support.cmake`: `CMAKE_LIBRARY_SUPPORT_DIR` cache entry now uses `FORCE` so the path updates correctly when a consumer upgrades the `GIT_TAG` in FetchContent without wiping their build directory.
- `github-release-dependency.cmake`: replaced deprecated `FetchContent_Populate` (single-argument form, deprecated in CMake 3.30) with `file(ARCHIVE_EXTRACT)`. Module now requires CMake 3.18+.

## [2.0.0] - 2026-05-04

### Added
- macOS 14 runner in the pure-CMake test matrix.
- `library_install_rules()` warns when `${PROJECT_SOURCE_DIR}/include` is missing.
- `generate-version.cmake` handles missing git, non-repo source directories, and detached HEAD.
- `generate_config_template()` accepts `STATIC`, `SHARED`, and `INTERFACE` flags to control
  which target includes are emitted in the generated config template. Defaults to all three
  if no flags are provided.
- `library_install_rules()` now treats `STATIC_TARGET`, `SHARED_TARGET`, and
  `INTERFACE_TARGET` as optional — each install block activates only when its corresponding
  argument is provided. At least one must still be specified.
- `CHANGELOG.md`.

### Changed
- **BREAKING**: entry-point file renamed from `cmake/cmake-utilities.cmake` to
  `cmake/cmake-library-support.cmake`. Update your top-level `include(...)` accordingly.
- **BREAKING**: `target_enable_coverage(target)` is now `target_enable_coverage(TARGET name)`.
- Minimum required CMake version bumped from 3.14 to 3.15.

### Removed
- **BREAKING**: `find-modules.cmake` removed. Use config-mode packaging
  (`install-rules.cmake` + `config-template.cmake`) instead.

## [1.2.0] - 2026-04-23

### Added
- Documentation for looking up GitHub release asset IDs using the `gh` CLI.

## [1.1.0] - 2026-04-09

### Changed
- Refactored `find-modules.cmake` to reduce generated boilerplate and consolidate
  find-module logic into a single file.

## [1.0.0] - 2026-04-09

### Added
- `coverage.cmake` — Clang source-based coverage with HTML reporting and 100% line
  coverage enforcement via `llvm-profdata` and `llvm-cov`.
- `generate-version.cmake` — Git-based version stamping; appends commit hash and `-dirty`
  suffix on non-release branches.
- `github-release-dependency.cmake` — Fetches private GitHub release assets using
  `GH_TOKEN` with SHA256 cache validation and sanitized error output.
- `config-template.cmake` — Generates `*-config.cmake.in` templates for
  `configure_package_config_file()`.
- `install-rules.cmake` — Installs library targets with CMake export sets, config-mode
  package files, and optional Doxygen documentation.
- `package-rules.cmake` — Configures CPack for TGZ/ZIP archive generation with system
  name and architecture in the filename.

[Unreleased]: https://github.com/donut-engineer/cmake-library-support/compare/v2.6.0...HEAD
[2.6.0]: https://github.com/donut-engineer/cmake-library-support/compare/v2.5.0...v2.6.0
[2.5.0]: https://github.com/donut-engineer/cmake-library-support/compare/v2.4.0...v2.5.0
[2.4.0]: https://github.com/donut-engineer/cmake-library-support/compare/v2.3.0...v2.4.0
[2.3.0]: https://github.com/donut-engineer/cmake-library-support/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/donut-engineer/cmake-library-support/compare/v2.1.3...v2.2.0
[2.1.3]: https://github.com/donut-engineer/cmake-library-support/compare/v2.1.2...v2.1.3
[2.1.2]: https://github.com/donut-engineer/cmake-library-support/compare/v2.1.1...v2.1.2
[2.1.1]: https://github.com/donut-engineer/cmake-library-support/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/donut-engineer/cmake-library-support/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/donut-engineer/cmake-library-support/compare/v1.2.0...v2.0.0
[1.2.0]: https://github.com/donut-engineer/cmake-library-support/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/donut-engineer/cmake-library-support/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/donut-engineer/cmake-library-support/releases/tag/v1.0.0
