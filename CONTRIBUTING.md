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

There is no automated test suite. Before submitting a PR, manually verify your module works correctly when consumed by a real CMake project via `FetchContent`. Document the test scenario in your PR description.

## Commit messages

- Imperative mood, short subject line (≤ 72 chars): `Add header discovery to find-modules`
- Reference any related issue in the commit body.

## License

By contributing you agree that your changes will be licensed under the [MIT License](LICENSE).
