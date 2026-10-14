---
name: project-skills-setup
description: Discover, select, and bootstrap project-specific agent skills using the Vercel skills CLI. Use when setting up skills for a new project or revisiting an existing project's skills.
---

# Project skills setup

Global skills remain available in every project; project skills supplement them.

1. **Inspect the project.** Read project instructions, manifests, dependency
   lockfiles, representative code, tests, and CI/deployment configuration. Inventory
   existing project and global skills, including skills already available to the agent.
2. **Clarify the workflow.** Briefly summarize the detected stack. Ask focused
   questions about goals and missing context; for an empty project, establish the
   intended stack first.
3. **Discover candidates.** Search with the Vercel CLI for relevant languages,
   frameworks, testing, data, deployment, and workflows. Include matching personal
   skills. Inspect candidates' instructions and source repositories before recommending.
4. **Let the user select.** Present a concise shortlist with skill name, source,
   relevance, and recommendation. Use the question tool with multiple selection;
   offer further searches if needed. Wait for selection before installing.
5. **Install the selection.** Resolve Git sources to full commit SHAs. Install
   only selected skills at project scope for OpenCode. Preserve existing skills
   and lock entries; avoid duplicate or conflicting global skill names.
6. **Make restoration repeatable.** Keep `skills-lock.json` version-controlled and
   ignore `/.agents/skills/`. Add a project bootstrap task using `skills-bootstrap`;
   copy that helper into project scripts when a self-contained bootstrap is needed.
   Bootstrap must restore pinned versions and verify hashes without updating the lock.
7. **Verify and report.** Run bootstrap and list installed skills. Confirm the
   agent discovers project and global skills; don't replace global discovery with
   a project-only configuration. Report selections and the exact bootstrap command.

## CLI

Use the pinned CLI version consistently, from the project root:

```sh
npx --yes skills@1.7.2 list --agent opencode
npx --yes skills@1.7.2 list --global --agent opencode
npx --yes skills@1.7.2 find '<query>'
npx --yes skills@1.7.2 add '<owner/repo>' --list
npx --yes skills@1.7.2 add '<owner/repo>#<commit-sha>' --skill '<name>' --agent opencode --yes
skills-bootstrap
```

Use chat selection while operating as an agent. The user can also run
`npx --yes skills@1.7.2 add <source>` interactively in their own terminal.
