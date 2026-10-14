---
name: python-pytest
description: Write and review Python tests using pytest, fixtures, pytest-mock, pytest-asyncio, and pytest-cov.
---

# Python testing with pytest

Load and follow `unit-testing-guidelines` for general testing policy.

1. **Use pytest functions.** Write typed `test_*` functions returning `None` in
   `test_*.py` files. Follow the project's layout and test command.
2. **Use native assertions.** Prefer plain `assert`, `pytest.approx` for numeric
   tolerances, and `pytest.raises(ExpectedError, match=...)` for errors. Keep only
   the raising action inside the context; it counts as the assertion.
3. **Parametrize cases.** Use `pytest.mark.parametrize` with descriptive case IDs
   for repeated scenarios.
4. **Use explicit fixtures.** Compose small fixtures for reusable setup. Default
   to function scope; reserve `autouse` for suite-wide invariants. Keep fixtures
   local until shared, then use the nearest relevant `conftest.py`.
5. **Make data configurable.** Use `make_*` factory fixtures with explicit
   overrides when tests need variants or multiple fresh objects.
6. **Clean up resources.** Use context managers or `yield` fixtures, typed as
   `Iterator[T]`. Protect partial setup failures before reaching `yield`.
7. **Use built-in helpers.** Prefer `tmp_path`, `monkeypatch`, `capsys`, and
   `caplog` for files, environment changes, output, and logging.
8. **Mock with pytest-mock.** Use `mocker`, patch where names are looked up, and
   prefer `autospec=True`. Use `mocker.AsyncMock` for async collaborators.
9. **Test async code with pytest-asyncio.** Follow the configured mode and loop
   scopes. Strict mode requires `pytest.mark.asyncio` and
   `pytest_asyncio.fixture`; await work and close async resources.
10. **Measure with pytest-cov.** Use branch coverage and missing-line reports to
    locate untested paths. Preserve the project's coverage configuration.
