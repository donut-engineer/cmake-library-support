# Contributing

## Branching model

- `develop` is the integration branch. All PRs target `develop`.
- `release` is tagged and reflects the latest stable version. Never commit directly to `release`.

## Submitting a change

1. Fork the repository.
2. Branch off `develop` with a descriptive name (e.g. `feature/install-components`).
3. Make your changes and test them in a real downstream CMake project (see [Testing](#testing)).
4. Open a PR against `develop` with a clear description of what changed and why.

## Module scope

Only modules that serve a C++ library author's build and release pipeline belong here — coverage reporting, version stamping, dependency fetching, install/package/find-module generation. If a module doesn't fit that description, it doesn't fit this repo.

## Style conventions

- Function names: `snake_case`
- Use `cmake_parse_arguments` for all public function parameters — no positional arguments.
- Keep each module self-contained and independently `include()`-able.
- Follow the casing conventions of the CMake version you're targeting: built-in commands lowercase, variables uppercase.

## Testing

The repo ships two test suites under `tests/`:

- **Pure-CMake tests** (`-L cmake-only`) — exercise the modules through `cmake --configure` and `cmake -P` without a C++ compiler.
- **Integration tests** — build a minimal consumer library (`tests/integration/mylib/`) with Clang + LLVM 18, run its GoogleTest suite, and produce a 100% line-coverage report.

Run locally:

```bash
cmake -S tests -B tests/build -DMODULES_DIR=$PWD/cmake
ctest --test-dir tests/build --output-on-failure -L cmake-only   # fast, no compiler needed
ctest --test-dir tests/build --output-on-failure                 # full suite, requires Clang + LLVM 18
```

CI runs both suites on every PR (Ubuntu 24.04 + macOS 14 for the pure-CMake suite; Ubuntu 24.04 with Clang 18 for the integration suite). See `.github/workflows/ci.yml`.

## Releasing

1. Confirm `develop` is green on CI.
2. Update `CHANGELOG.md`: move `[Unreleased]` content into a new `[X.Y.Z] - YYYY-MM-DD` section and refresh the bottom-of-file links.
3. Open a PR `develop` → `release` and merge with a merge commit (not squash, so tag history is preserved).
4. From `release`, create an annotated tag and push it: `git tag -a vX.Y.Z -m "vX.Y.Z" && git push origin vX.Y.Z`. Use annotated tags — lightweight tags are invisible to `git describe` by default and carry no tagger or message metadata. (`generate-version.cmake` itself only reads the branch name and `git rev-parse --short HEAD`, so the choice is mostly about tooling and convention.)
5. Draft a GitHub Release for the tag and paste the new CHANGELOG section into the body.

## Commit messages

- Imperative mood, short subject line (≤ 72 chars): `Add SameMajorVersion compatibility to install-rules`
- Reference any related issue in the commit body.

## License

By contributing you agree that your changes will be licensed under the [MIT License](LICENSE).
