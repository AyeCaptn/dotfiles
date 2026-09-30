---
name: hunk-comment-review
description: Automates an interactive, comment-by-comment review of human notes in a live Hunk session. Use when the user asks to process Hunk comments, address review feedback, or walk through review notes together.
---

# Hunk Comment Review

Use this workflow to address human-authored Hunk comments collaboratively. Do not run interactive Hunk commands such as `hunk diff` or `hunk show`.

## Load Hunk's current instructions

Hunk owns the authoritative CLI instructions. At the start of every review:

1. Run `hunk skill path`.
2. Read the returned `SKILL.md` completely.
3. Follow it for all Hunk session operations.

Do not copy assumptions about Hunk commands from this skill when the loaded Hunk skill differs.

## Start the review

1. Run `hunk session list --json` and select the session for the current repository.
2. If no matching session exists, ask the user to launch Hunk in their terminal and stop.
3. Inspect the diff structure with `hunk session review --repo . --json`.
4. List human notes with `hunk session comment list --repo . --type user --json`.
5. Preserve their returned order unless dependencies make another order clearer.

## Process comments one by one

For each unresolved human note:

1. Navigate to it with `hunk session navigate --repo . --comment <note-id> --json`.
2. Read enough surrounding source, diff, tests, and configuration to understand the feedback. Use `review --include-patch` only when raw diff content is necessary.
3. State the comment being considered and give a concise assessment.
4. If the correct change is unambiguous and within the user's request, implement it, run focused validation, and report the result before moving on.
5. If the comment asks a design question, has multiple reasonable solutions, changes behavior or public APIs, or depends on user preference, ask one focused question and wait. Offer concise choices and recommend one when appropriate.
6. Do not silently decide ambiguous feedback and do not process later comments while waiting for an answer.
7. After resolving a note, optionally reply to it through Hunk when a durable explanation is useful. Never remove human-authored comments unless explicitly asked.
8. Move to the next comment only after the current comment is resolved or the user explicitly defers it.

## Editing rules

- Keep edits scoped to the active comment.
- Respect existing project style and instructions.
- Treat pre-existing working-tree changes as user work; do not overwrite or revert them.
- Run the narrowest useful tests or checks after each logical edit, then broader validation at the end when practical.
- If several comments require the same architectural fix, explain the relationship before combining their implementation.

## Communication

- Keep the Hunk viewport aligned with the active note.
- Number progress as `Comment N of M`.
- Quote or summarize the active note so the user knows what is under discussion.
- Separate findings from proposed action.
- When asking a question, stop and wait for the answer.
- At completion, summarize resolved, deferred, and unchanged comments plus validation results.
