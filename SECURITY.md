# Security Policy

## Reporting a vulnerability

If you find a security issue — particularly anything that could leak `GH_TOKEN` or other secrets through `github-release-dependency.cmake` — please report it privately rather than opening a public issue.

Open a [private security advisory](https://github.com/donut-engineer/cmake-library-support/security/advisories/new) on GitHub. We aim to acknowledge reports within 7 days.

## Supported versions

Only the latest minor release receives fixes. Pin a specific tag in `FetchContent` (`GIT_TAG vX.Y.Z`) to avoid surprise updates.
