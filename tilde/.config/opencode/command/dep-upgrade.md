---
description: Upgrade dependencies in lock file and pyproject.toml
allowed-tools: Read, Grep, Edit, Bash(uv sync:*), Bash(uv pip list), Bash(uv run pre-commit autoupdate), Bash(just format), Bash(just test-all)
---

1. Run `uv sync --upgrade --all-groups` to upgrade all dependencies
2. Find all dependencies explicitly mentioned in the pyproject.toml file. Use `uv pip list` to show the packages that
   are now installed.
3. Update the minimum version constraints in pyproject.toml to match the exact versions from the `uv pip list` output
   (e.g., change `>=2,<3` to `>=2.4.0,<3` if lockfile shows 2.4.0). If versions already match, skip to next step.
4. Run `uv sync --all-groups` again to ensure the updated constraints work (skip if no changes were made)
5. Run `uv sync --all-groups` again to install the updated pinned versions (skip if no changes were made)
6. Run `make format` and fix any formatting issues (run again if files were modified)
7. Run `make test` to verify all tests still pass

Important notes:

- Preserve all comments in pyproject.toml
- Unless explicitly noted, DO NOT upgrade to pre-release or alpha versions. Upgrade only to stable versions.

Files included in context:

- @pyproject.toml
