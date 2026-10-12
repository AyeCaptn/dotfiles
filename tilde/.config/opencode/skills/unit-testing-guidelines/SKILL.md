---
name: unit-testing-guidelines
description: Apply language-independent unit-testing guidelines when writing, changing, or reviewing unit tests, choosing test cases, or planning regression coverage. Use the project's framework-specific skills for syntax and tooling.
---

# Unit testing guidelines

Write fast, trustworthy tests that catch meaningful regressions.

1. **Follow the project.** Read its instructions and nearby tests; use its
   framework, conventions, and applicable framework-specific testing skill.
2. **Test observable behavior.** Exercise interfaces real callers use. Preserve
   refactor freedom; don't expose private methods solely for tests. Hard-to-test
   complex logic may indicate a missing abstraction.
3. **One assertion per test.** Each case has exactly one assertion, including
   helper, exception, and mock assertions. Don't disguise multiple checks in
   helpers or boolean expressions. Whole-value equality is fine for one contract.
4. **Make intent obvious.** Name the scenario and expected outcome; use
   Arrange–Act–Assert with one principal action and minimal, explicit setup.
5. **Keep tests simple.** Avoid branching and duplicated production algorithms.
   Use parameterization for repeated cases; prefer clarity over elaborate shared
   fixtures. Small amounts of duplication are acceptable.
6. **Assert independently.** Use explicit expected values derived from the
   contract. Prefer precise results over truthiness or non-null checks.
7. **Choose cases by risk.** Establish a happy-path baseline, then vary relevant
   conditions for meaningful boundaries and errors. Use coverage to find gaps;
   prioritize plausible regressions.
8. **Keep execution deterministic.** Use fresh state; control time, randomness,
   and environment. Await async work, avoid arbitrary sleeps, and clean up
   resources even after failures.
9. **Substitute at boundaries.** A unit may include real, lightweight
   collaborators. Replace slow or unpredictable I/O; verify interactions only
   when they're contractual. Use integration tests for real infrastructure.
10. **Verify the evidence.** Test-first is optional. For bug fixes, reproduce the
    defect with a failing regression test when practical. Run focused tests,
    relevant suites, and required checks; report actual results. Investigate
    failures before changing expectations.
