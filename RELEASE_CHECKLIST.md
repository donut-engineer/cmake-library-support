# Release-Readiness Checklist

A pre-public-release review of `cmake-library-support`. Each item is a small,
surgical fix — no module rewrites required.

## P0 — Must fix before going public

### 1. `CONTRIBUTING.md:28` claims there is no test suite

> "There is no automated test suite. Before submitting a PR, manually verify..."

This is false as of v2.0.0. `.github/workflows/ci.yml` runs:

- pure-CMake tests on `ubuntu-24.04` and `macos-14`
- integration tests with Clang + LLVM 18 on `ubuntu-24.04`
- coverage report upload artifact

**Fix**: Rewrite the *Testing* section to point at `tests/`, describe the two
suites (`-L cmake-only` vs the LLVM-required integration), give the local
`cmake -S tests -B tests/build && ctest --test-dir tests/build` command, and
note that CI runs both on every PR.

### 2. CMake minimum version is inconsistent across the test tree

v2.0.0 bumped the floor from 3.14 to 3.15 (`CHANGELOG.md:28`,
`cmake/cmake-library-support.cmake:13` enforces with `FATAL_ERROR`). But four
test CMakeLists still declare `cmake_minimum_required(VERSION 3.14)`:

- `tests/CMakeLists.txt:1`
- `tests/cmake-only/test-cmake-library-support/CMakeLists.txt:1`
- `tests/cmake-only/test-config-template/CMakeLists.txt:1`
- `tests/cmake-only/test-install-rules/CMakeLists.txt:1`

(`tests/integration/mylib/CMakeLists.txt:1` is already 3.15.)

**Fix**: Bump all four to 3.15.

### 3. README has no CI status badge

`README.md:3` only shows the MIT badge.

**Fix**: Add immediately under the title:

```markdown
[![CI](https://github.com/donut-engineer/cmake-library-support/actions/workflows/ci.yml/badge.svg)](https://github.com/donut-engineer/cmake-library-support/actions/workflows/ci.yml)
```

### 4. README "Requirements" doesn't pin the LLVM version

`README.md:9–10` says "Clang + LLVM toolchain" but `cmake/coverage.cmake:28-29`
prefers `llvm-profdata-18` / `llvm-cov-18` and CI installs LLVM 18 explicitly.

**Fix**: Change to "Clang + LLVM 18 (older versions may work; CI tests against 18)."

## P1 — Public-repo polish

### 5. Add a "why this exists" lead paragraph to README

The current opener describes *what* the project does. Lead with *why*:
"Authoring a redistributable C++ library on CMake means stitching together
coverage, versioning, install rules, packaging, and find-modules from scratch
every time. This repo packages that boilerplate as seven independently-
includeable modules." Then keep the existing scope paragraph.

### 6. Advertise the integration test as a complete consumer example

`tests/integration/mylib/` is a fully-working downstream consumer (header,
src, tests, coverage hookup). It isn't linked from the README.

**Fix**: Add a "Complete example" line under `## Integration` pointing at
`tests/integration/mylib/CMakeLists.txt`.

### 7. Document the release process

CONTRIBUTING.md describes the `develop`/`release` branching model but not how
a release is actually cut. `generate-version.cmake` keys off the `release`
branch name, so this matters.

**Fix**: Add a short *Releasing* section: merge `develop` → `release`,
annotate-tag `vX.Y.Z` (use `git tag -a`, not lightweight), push branch + tag,
draft a GitHub Release with the CHANGELOG excerpt.

### 8. Add minimal `.github/` templates

No issue template, no PR template, no `SECURITY.md`. The repo handles `GH_TOKEN`
PATs (`cmake/github-release-dependency.cmake`), so a `SECURITY.md` with a
disclosure email is appropriate.

**Fix**: Add `.github/ISSUE_TEMPLATE/bug_report.md`,
`.github/PULL_REQUEST_TEMPLATE.md`, and a 10-line `SECURITY.md`. Keep all
three short.

### 9. Re-tag v1.1.0 and v1.2.0 as annotated

`git ls-remote --tags origin` shows v1.0.0 and v2.0.0 are annotated (have
`^{}` peel refs) while v1.1.0 and v1.2.0 are lightweight. Cosmetic, visible
in `git tag -n` and `git describe`.

**Fix** (low urgency): skip unless v1.x has zero `FetchContent` consumers —
force-pushing already-published tags can break downstream pins.

## P2 — GitHub-side / résumé (not code changes)

- Flip repo visibility to public (confirm via GitHub settings).
- Set repo description: e.g. *"Reusable CMake modules for authoring
  distributable C++ libraries: coverage, versioning, install rules, packaging,
  private GitHub release fetching."*
- Add topics: `cmake`, `cpp`, `code-coverage`, `cpack`, `library-template`,
  `clang-coverage`.
- Pin the repo on your GitHub profile.
- Resume bullet drafts:
  - "Authored a 7-module CMake library bundling 100% line-coverage gating,
    git-based version stamping, and CPack archive generation; consumed via
    `FetchContent` by downstream C++ projects."
  - "Built CI matrix (Ubuntu 24.04, macOS 14) running pure-CMake and
    Clang-LLVM-18 integration tests against every PR."
  - "Designed a private-release dependency fetcher that sanitizes `GH_TOKEN`
    from CMake error logs even on download failure."

## Critical files to modify

| File | Change |
|---|---|
| `CONTRIBUTING.md` | Rewrite *Testing* section; add *Releasing* section |
| `README.md` | Add CI badge, "why" lead paragraph, LLVM 18 note, integration-example pointer |
| `tests/CMakeLists.txt` | `3.14` → `3.15` |
| `tests/cmake-only/test-cmake-library-support/CMakeLists.txt` | `3.14` → `3.15` |
| `tests/cmake-only/test-config-template/CMakeLists.txt` | `3.14` → `3.15` |
| `tests/cmake-only/test-install-rules/CMakeLists.txt` | `3.14` → `3.15` |
| `.github/ISSUE_TEMPLATE/bug_report.md` | New (short) |
| `.github/PULL_REQUEST_TEMPLATE.md` | New (short) |
| `SECURITY.md` | New (~10 lines) |
| `CHANGELOG.md` | Add an `[Unreleased]` entry once the docs/test-version cleanup lands |

No source-code changes in `cmake/*.cmake` are required — the modules
themselves are release-quality.

## Verification

After making the changes:

1. `cmake -S tests -B tests/build -DMODULES_DIR=$PWD/cmake` — must succeed
   with the bumped 3.15 minimums.
2. `ctest --test-dir tests/build --output-on-failure -L cmake-only` — pure-CMake
   tests pass on a machine without Clang.
3. With Clang + LLVM 18 installed: `ctest --test-dir tests/build
   --output-on-failure` — full suite including integration coverage at 100%.
4. Render `README.md` on GitHub and confirm the CI badge resolves.
5. Open a draft PR against `develop` and confirm the new
   `PULL_REQUEST_TEMPLATE.md` populates the body.
6. After merge to `develop` → `release`, tag the next release and confirm
   the GitHub Actions badge stays green for the `release` branch.
