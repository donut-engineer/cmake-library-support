# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `generate_config_template()` now accepts `STATIC`, `SHARED`, and `INTERFACE` flags to
  control which target includes are emitted in the generated config template. Defaults to
  all three if no flags are provided (backward compatible).
- `library_install_rules()` now treats `STATIC_TARGET`, `SHARED_TARGET`, and
  `INTERFACE_TARGET` as optional — each install block activates only when its corresponding
  argument is provided. At least one must still be specified.

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

[Unreleased]: https://github.com/donut-engineer/cmake-library-support/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/donut-engineer/cmake-library-support/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/donut-engineer/cmake-library-support/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/donut-engineer/cmake-library-support/releases/tag/v1.0.0
