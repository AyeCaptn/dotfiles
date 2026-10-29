---
name: review-comments
description: Walk through human-authored review comments with the user, one at a time. Use when the user says "review", "review my comments", or asks to discuss their review feedback. Not an independent code or pull-request audit.
---

# Review comments

Use the human comments and their file paths, line ranges, or diff locations
supplied in the prompt or conversation. Read all supplied comments for context,
but discuss one at a time. If comments or locations are missing or ambiguous,
ask the user for them; do not invent feedback or assume access to a review tool.

For each comment:

1. Identify it as `Comment N of M`, with its file and location. Quote or briefly
   summarize the feedback so the user knows which comment is being discussed.
2. Read the relevant code or document and current diff. Locations may refer to an
   older version; find the matching content rather than trusting line numbers alone.
3. Answer the question or assess the request. Offer a concrete recommendation and
   explain meaningful tradeoffs without treating every comment as a change request.
4. Use the question tool for decisions or approval. Discuss the current comment
   until the user agrees on a resolution or defers it. Do not silently group
   comments, implement all feedback, or advance through the list without agreement.
5. Implement only requested or agreed changes, following the applicable checkout,
   permission, and validation rules. Verify the fix and report its outcome before
   moving on. If a fix affects another comment, acknowledge it when that comment
   is reached rather than silently skipping it.

Track addressed, deferred, and unresolved comments in the conversation; do not
create a tracking file or mark comments resolved in the app without authorization.
Finish with a brief summary of decisions, changes, and remaining feedback.
