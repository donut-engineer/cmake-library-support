# Security Policy

## Reporting a Vulnerability

Please **do not** open a public GitHub issue for security vulnerabilities. Instead, email **tdcarter427@gmail.com** with a description of the issue and steps to reproduce. You will receive a response within 72 hours.

## Token Handling in `github-release-dependency.cmake`

This module accepts a GitHub personal access token via the `GH_TOKEN` environment variable. The following protections are in place:

- The token is read from the environment and passed via `curl` headers — it is never written to any file or CMake cache variable.
- If a download fails, the error log is sanitized before display: all occurrences of the token value are replaced with `***` so the PAT is never exposed in build output or CI logs.
- The token is not stored between CMake runs.

**Recommended token scope**: `repo` (read access is sufficient for downloading release assets from private repositories).

**If your token is compromised**: revoke it immediately at [github.com/settings/tokens](https://github.com/settings/tokens) and generate a new one.
