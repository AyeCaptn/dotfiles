---
name: hunk-comment-review
description: Address human-authored comments in a live Hunk session, grouping comments that share an underlying issue or resolution. Use when processing Hunk feedback or walking through review notes together.
---

# Hunk Comment Review

Run `hunk skill path`, read the returned file completely, and follow it for all
Hunk operations.

Read all human comments and enough relevant code to identify related feedback.
Group comments when one discussion, decision, or fix can resolve them together.
Keep unrelated requests separate, even when they concern the same file.

Review each comment or group in turn:

1. Focus the comment or a representative comment in Hunk. Briefly identify it as
   `Comment N of M`, or list the comment numbers and shared issue for a group.
2. Read the relevant code for every included comment, then answer the questions
   or assess the requests. Preserve any distinct concerns within a group.
3. Offer useful ideas and a concrete proposal. Raise implementation questions
   where needed, explain tradeoffs, and recommend an approach.
4. Discuss the current comment or group with the user. Implement when requested
   or agreed; don't treat a question as an instruction to change code.
5. Stay on that comment or group until the discussion is settled or the user
   defers it. Wait for answers before moving on. Split out any comment that needs
   a separate decision; don't skip comments silently.
6. After an agreed fix, verify that it addresses every comment in the group and
   track each comment's outcome. Revisit any remaining concern separately.

Keep the conversation concise and collaborative. Finish with a brief summary of
decisions, changes, and remaining comments.
