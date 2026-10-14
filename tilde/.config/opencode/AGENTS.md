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

# Project validation

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

# Keep output lean

- Use ASD-STE100-inspired language: short sentences, direct wording, and consistent
  terminology. Omit filler and repetition.
- Keep explanations and unsolicited documentation brief, direct, and developer-focused.
  Document stable intent or constraints; avoid duplicating code details that need syncing.
- Create files, schemas, and scripts only when required by the task or core project
  structure. Avoid speculative helpers, generated paperwork, and unused artifacts.
