---
description: Initialize project skills, checks, and agent guidance
agent: build
subagent: false
---

Initialize this project. User focus: $ARGUMENTS

1. Inspect README, instructions, manifests, tooling, CI, and key entrypoints.
   Trust executable config over prose. Establish the stack if the project is empty.
2. Load and follow `project-skills-setup`, then `project-checks-setup`.
3. Improve `AGENTS.md` in place with verified, repo-specific guidance:
   setup and validation commands (including focused tests), non-obvious package
   boundaries, conventions, and tooling or test prerequisites. Include only what
   an agent would likely miss; preserve useful guidance and omit generic advice
   or duplicated global instructions.
4. Run the configured fast and full checks. Report skills, bootstrap and check
   commands, results, and blockers briefly.

Reuse working setup on reruns. Batch decisions with the question tool; ask only
for unresolved choices. Honor skill approvals and environment confirmation rules.
