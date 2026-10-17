---
name: pull-request
description: Create or update a GitHub PR with a clear overview of new features, fixes, validation, and web-app review links. Use when asked to open a PR or write its title or description.
---

# Pull request

Make the change easy to understand and review. Follow the repository's PR
template; otherwise use the compact structure below, omitting irrelevant sections.

1. **Read the whole change.** Inspect repository instructions, working-tree
   status, commits, and the full diff against the intended base. Summarize what
   will actually be included, not just the latest commit or the conversation.
2. **Lead with value.** Write a short, specific title and explain what changes
   for users and why. Group related features and fixes; mention internal changes
   only when useful to reviewers. Avoid file inventories, hype, and filler.
3. **Make web changes reviewable.** Find the branch's actual preview URL from
   deployment checks, PR comments, or project tooling. Link directly to affected
   pages and give a brief action and expected result for each important flow.
   Verify links with the active client's browser when available; distinguish
   link availability from tested behavior. Note login, flags, or setup needed
   without exposing secrets. Label local-only URLs and say when a preview is
   unavailable or unverified. Never invent URLs, imply production has the change,
   or deploy or publish a preview without approval. Add screenshots only when
   they clarify a visual change.
4. **Report evidence.** List checks actually run and their results, including
   relevant failures or skipped checks. Mention breaking changes, rollout needs,
   or known limitations only when applicable. Don't claim unperformed testing.
5. **Create or update deliberately.** Use `gh`; check for an existing PR and
   confirm the base and head. Preserve human-written content when updating.
   Follow approval rules for pushing or publishing; drafting text alone does
   not authorize either. Register the PR with the active client's linking tool
   when available, then return its URL.

```markdown
## What's new
- <Feature or fix and its benefit.>

## Review
- [<Changed page>](<actual URL>) — <action → expected result>.

## Validation
- <Check run — result; important gaps if any.>
```
