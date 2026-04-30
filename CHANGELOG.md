# Changelog

All notable changes to this project will be documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] — 2026-04-29

### Added
- `coverage.cmake` — Clang source-based coverage with 100% line enforcement and HTML reporting
- `generate-version.cmake` — Git-based version stamping with release/dev branch logic
- `github-release-dependency.cmake` — Private GitHub release asset fetcher with token sanitization
- `config-template.cmake` — Config-mode package template generator
- `install-rules.cmake` — Installation rules for static, shared, and interface library variants
- `package-rules.cmake` — CPack configuration for TGZ/ZIP distribution archives
- `cmake-library-support.cmake` — Entry point that sets `CMAKE_MODULE_PATH`
- Pure CMake test suite (no compiler required)
- Integration test suite with GoogleTest and coverage validation
- GitHub Actions CI pipeline with LLVM 18 and coverage artifact upload
- MIT license, contributing guidelines, and FetchContent integration documentation
