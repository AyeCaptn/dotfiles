---
name: pragmatic-coding
description: Apply language-independent coding principles when implementing, refactoring, or reviewing code. Favor clear, focused solutions, proportionate error handling, and minimal speculative complexity.
---

# Pragmatic coding

Write the simplest clear solution that satisfies the actual requirements.

1. **Solve today's problem.** Follow existing conventions and reuse available
   tools. Add features, dependencies, configuration, and extensibility only for
   concrete requirements.
2. **Make contracts clear.** Validate external input at boundaries; trust
   established types and internal invariants. Handle supported edge cases without
   inventing extra input formats, coercions, or repeated defensive checks.
3. **Fail clearly.** When an operation cannot proceed, raise an appropriate
   existing exception with useful context. Preserve its cause. Don't turn
   unexpected failures into empty results, default values, or apparent success.
4. **Recover deliberately.** Catch errors when you can recover, translate them
   at an application boundary, or clean up resources. Otherwise let them
   propagate. Add retries and fallbacks only when required and meaningful.
5. **Make abstractions earn their place.** Extract code when it hides meaningful
   complexity or represents a stable shared concept. Avoid pass-through wrappers,
   speculative frameworks, and splitting cohesive logic into tiny helpers.
6. **Share knowledge, not resemblance.** Centralize rules that must change
   together. Allow small duplication when similar-looking code has different
   responsibilities; avoid shared helpers burdened with flags and branches.
7. **Keep flow obvious.** Use direct control flow and clear domain names. Keep
   state and side effects local; pair resource acquisition with cleanup.
   Prefer readability over clever compression or arbitrary function-length rules.
8. **Explain what matters.** Use concise comments for intent, constraints, and
   non-obvious decisions. Avoid narrating code or generating redundant documentation.
9. **Simplify before finishing.** Review the changed code for unnecessary guards,
   layers, and branches. Verify required behavior; use `unit-testing-guidelines`
   for testing policy.
