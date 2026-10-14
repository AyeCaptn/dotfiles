---
name: project-checks-setup
description: Set up fast iteration checks and thorough completion checks tailored to a project's stack. Use when creating or improving check commands, validation workflows, or developer feedback tooling.
---

# Project checks setup

- Inspect dependencies, existing tooling, tests, CI, and project instructions.
  Briefly agree on useful checks. Favor fast, modern tooling suited to the actual
  stack; discuss changes to existing tools rather than hardcoding language defaults.
- Put Bash implementations in `scripts/check.sh`, `scripts/check-all.sh`,
  `scripts/test.sh`, and `scripts/format.sh`. Keep Makefile targets `check`,
  `check-all`, `test`, and `format` as thin recipes invoking those scripts;
  preserve existing targets.
- **`make check`:** fast lint, formatting verification, typechecking, and useful
  focused tests. Aim for a few seconds; measure runtime.
- **`make check-all`:** fast checks plus the relevant full test suites, configured
  coverage, and stack-specific diagnostics such as React Doctor when useful.
- **`make format`:** apply formatting. Check commands must not auto-fix code.
- **`make test`:** run tests, with arguments to select files or cases using the
  project's test runner.
- Run tools through the project's environment or package manager.
- Keep Bash scripts simple; use `set -euo pipefail`. Show short status summaries
  and bounded, actionable failure output. Preserve failure exit codes and access
  to full logs; report skipped checks.
- Honor environment confirmation rules. Verify runtime, success, and failure
  reporting. Add only the invocation commands to project `AGENTS.md`.

Use `make check` while iterating and `make check-all` before finishing.
