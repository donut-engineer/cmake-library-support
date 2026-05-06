## Summary

<one paragraph: what changed and why>

## Verification

- [ ] `ctest --test-dir tests/build --output-on-failure -L cmake-only` passes
- [ ] If touching `coverage.cmake` or the integration path: full `ctest` passes with Clang + LLVM 18
- [ ] `CHANGELOG.md` `[Unreleased]` updated if user-visible
