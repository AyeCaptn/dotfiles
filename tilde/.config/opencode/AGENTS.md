# Confirmation before environment changes

- Ask before Docker builds or pushes unless explicitly requested.
- Always confirm deployments (dev/UAT/prod), database writes, migrations, and
  schema changes.
- Confirm other shared-environment mutations, including infrastructure, services,
  jobs, artifact publishing, configuration, secrets, permissions, and deletion.
- State the action, target, and effect; wait for approval. Reconfirm if scope or
  target changes. Testing or validation requests don't authorize these actions.

# Starting substantial tasks

Use `ticket-kickoff` for a brief pair-programming discussion before substantial
implementation. Skip small, straightforward edits; don't produce plans or planning files.

# Checkout state and coordination

- Before the first edit, inspect checkout state and upstream status. If there is
  pre-existing uncommitted work or unpushed commits, ask whether to commit/push
  them or intentionally leave them pending before proceeding. Do not commit,
  push, stash, discard, or overwrite existing work without approval.
- Coordinate or sequence concurrent tasks touching the same files; separate
  worktrees do not prevent overlapping edits.

# Long-running local jobs

- Prefer a named, detached `tmux` session for long-running encoding, uploads,
  backups, and similar jobs so they survive terminal disconnection and can be
  reattached. Report the session name and retain a log and exit status.
- On macOS, also use `caffeinate -i` around jobs that must prevent idle sleep.
  It complements `tmux`; `tmux` alone does not prevent sleep. Neither protects
  against shutdown, forced sleep, or disconnected external storage.
- Do not interrupt or restart an active job just to move it into `tmux`.

# Project validation

Verify required paths and project dependencies before running validation.
Dependency installation remains subject to the existing approval rules.
Use the project's fast check while iterating and its full check before finishing.
Use `project-checks-setup` when asked to create or improve these commands.
Use the project's formatting command and configuration, such as `make format`
when provided. Use its configured language tools and runner rather than choosing
a separate formatter.

# User input

- Use the `question` tool when you need a decision, clarification, preference,
  or approval. Do not end with a plain-text question and wait for another prompt.
- Batch related configuration choices together and include concise recommendations.

# Documentation

Use Grounded Docs for library APIs; inspect project versions and automatically index
missing official docs. Its private local index at `~/.local/share/grounded-docs` is
approved for automatic writes, migrations, and refreshes. Other databases still need confirmation.

# Review tools

- Use `gh` for GitHub pull requests and GitHub Actions status and logs.
- Use Hunk for interactive diff review and `hunk-comment-review` for human feedback.
- Use the active client's browser tools for browser interaction and page screenshots.
- Prefer dedicated file-search tools over shell globs.
- After two similar preview failures, diagnose or report the blocker instead of
  repeating unchanged attempts.

# Keep output lean

- Use short, direct sentences and consistent terminology.
- Lead with the answer. Include only what the user needs to understand, decide, or act.
- State each point once. Omit investigation narratives and unnecessary implementation detail.
- Apply this to responses and generated docs. Expand only when requested or necessary.
- Create files, schemas, and scripts only when required by the task or core project
  structure. Avoid speculative helpers, generated paperwork, and unused artifacts.
