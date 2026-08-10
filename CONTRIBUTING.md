# Contributing to EnderOS

Thank you for helping improve EnderOS.

## Ground Rules

1. Read [docs/AI_CONTEXT.md](docs/AI_CONTEXT.md) before proposing changes.
2. Keep components focused on a single responsibility.
3. Prefer shared assets and reusable scripts over duplication.
4. Preserve Arch Linux portability.
5. Avoid unrelated changes in the same pull request.

## Workflow

1. Fork and create a topic branch.
2. Keep commits small and reviewable.
3. Run local checks before opening a pull request.
4. Use the pull request template and complete all checklist items.

## Pull Request Expectations

- Explain problem and solution clearly.
- List modified modules and behavior changes.
- Mention dependency or portability impact.
- Update docs when behavior or structure changes.

## Style

- Scripts should use `set -euo pipefail`.
- Prefer clear naming and small functions.
- Keep output portable and readable.
