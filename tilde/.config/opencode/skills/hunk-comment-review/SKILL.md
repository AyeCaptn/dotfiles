---
name: hunk-comment-review
description: Address human-authored comments in a live Hunk session, one at a time. Use when processing Hunk feedback or walking through review notes together.
---

# Hunk Comment Review

Run `hunk skill path`, read the returned file completely, and follow it for all
Hunk operations.

Review every human comment one by one:

1. Focus the comment in Hunk and briefly identify it as `Comment N of M`.
2. Read the relevant code, then answer the question or assess the request.
3. Offer useful ideas and a concrete proposal. Raise implementation questions
   where needed, explain tradeoffs, and recommend an approach.
4. Discuss the current comment with the user. Implement when requested or agreed;
   don't treat a question as an instruction to change code.
5. Stay on that comment until the discussion is settled or the user defers it.
   Wait for answers before moving on; don't batch comments or skip any silently.

Keep the conversation concise and collaborative. Finish with a brief summary of
decisions, changes, and remaining comments.
