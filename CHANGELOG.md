# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- `github-release-dependency.cmake`: added `FETCHCONTENT_BASE_DIR` fallback to `${CMAKE_BINARY_DIR}/_deps` so the module works when the consumer has not called `include(FetchContent)` beforehand.
- `github-release-dependency.cmake`: archive is now re-extracted only when the SHA256 changes (stamp file), restoring the caching behaviour that `FetchContent_Populate` provided before it was replaced with `file(ARCHIVE_EXTRACT)`.

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

[Unreleased]: https://github.com/donut-engineer/cmake-library-support/compare/v2.1.0...HEAD
[2.1.0]: https://github.com/donut-engineer/cmake-library-support/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/donut-engineer/cmake-library-support/compare/v1.2.0...v2.0.0
[1.2.0]: https://github.com/donut-engineer/cmake-library-support/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/donut-engineer/cmake-library-support/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/donut-engineer/cmake-library-support/releases/tag/v1.0.0
