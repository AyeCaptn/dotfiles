---
name: OpenCode
description: Use for any question about OpenCode, including configuration, CLI, TUI, agents, skills, tools, permissions, MCP, providers, plugins, SDK, API, troubleshooting, and V1 to V2 migration. Use Grounded Docs first and automatically index missing official documentation.
---

# OpenCode

## Documentation workflow

Use Grounded Docs first for all OpenCode documentation, including configuration
and CLI behavior as well as library APIs. Instructions to read or fetch a guide
mean to retrieve its official content through Grounded Docs first.

1. Use `find_version` for library `opencode` and version `v2`. Use
   `list_libraries` when the library ID is unknown.
2. Use `search_docs` with the selected version and a focused topic query. Check
   that results cover the relevant guide and the detail needed for the task.
   Try a more specific query before treating an empty search as missing docs.
3. If the library or version is missing, automatically use `scrape_docs` with
   library `opencode`, version `v2`, URL `https://opencode.ai/v2/docs/`, and
   scope `subpages`. Inspect the returned job status with `get_job_info`; search
   again after indexing completes.
4. If the version exists but documentation is stale or incomplete, use
   `refresh_version`, inspect its job status, and search again. Do not scrape
   over an existing version or delete the index to repair a search miss.
5. If the required page is still absent, use Grounded Docs `fetch_url` for that
   official V2 page. Also use it when search excerpts omit necessary context,
   such as a complete configuration reference.
6. Use direct `webfetch` only when Grounded Docs is unavailable or cannot
   retrieve the required official content. Briefly explain the fallback.

Use Grounded Docs `fetch_url` for documentation discovery when needed, including
`https://opencode.ai/v2/llms.txt`. Direct fetching must not replace automatic
indexing when the library or version is missing. Do not claim that a fetched
page has been indexed unless an indexing job confirms it.

The private local Grounded Docs index at `~/.local/share/grounded-docs` is
approved for automatic writes, migrations, and refreshes. This approval does
not extend to other databases or shared environments.

## Version and source policy

- Answer for OpenCode V2 unless the user explicitly asks about V1, legacy
  OpenCode, or migration.
- Use official `https://opencode.ai/v2/docs/` documentation as the source of
  truth. Indexed source files from the official OpenCode repository are also
  valid when they correspond to those V2 pages.
- Do not use `https://opencode.ai/docs/` or general web search to resolve V2
  documentation questions covered by the V2 guides.
- The schema at `https://opencode.ai/config.json` may describe V1. Keep the
  published `$schema` in configuration files, but never infer V2 field names
  or shapes from it.
- If V2 documentation is missing or contradictory, state the uncertainty or
  ask for clarification. Do not substitute V1 behavior.

## Relevant guides

Retrieve the relevant guide before answering or editing. Paths below are
relative to `https://opencode.ai/v2/docs/`.

| Topic | Guide |
| --- | --- |
| CLI and terminal behavior | `cli` |
| Terminal settings and `cli.json` | `cli/config` |
| Keybind IDs, defaults, and syntax | `cli/keybinds` |
| Server and project configuration | `config` |
| Agents and instructions | `agents`, `instructions` |
| Skills and override precedence | `skills` |
| MCP servers and authentication | `mcp-servers` |
| V1 to V2 migration | `migrate-v1` |
| Plugins and plugin migration | `build/plugins` |
| CLI plugins | `build/plugins/cli` |
| Custom RPC methods and events | `build/plugins/rpc` |
| Server HTTP API | `api` |
| Network client | `build/client` |
| Embedded SDK | `build/sdk` |
| Effect SDK | `build/sdk/effect` |
| Cloudflare SDK | `build/sdk/cloudflare` |
| Service and troubleshooting | `troubleshooting` |

Follow links from these guides when more detail is required. Never guess
configuration fields, keybind commands, or API shapes.

## Operational guidance

- CLI preferences belong in global `~/.config/opencode/cli.json`, or its
  `$XDG_CONFIG_HOME` equivalent. Server and project settings belong in
  `opencode.json(c)`. Preserve unrelated settings when editing.
- Prefer `opencode mcp add` for MCP configuration. Use `--global` for
  user-wide setup and project scope when explicitly requested.
- For MCP OAuth, direct the user to `/mcps` to sign in. Do not launch an
  interactive shell authentication flow or store an API key in place of OAuth.
- For local API requests, use `opencode api` and the configured server and
  authentication context. The running server exposes `/openapi.json`.
- Diagnose service issues with `opencode service status`,
  `opencode api get /api/info`, and relevant logs. Service mutations remain
  subject to the applicable environment confirmation rules.
- Do not delete or edit persistent databases or service registrations during
  diagnosis. Redact secrets before sharing diagnostics.
- Read the migration guide before migration work and the plugin guide for
  plugin migrations. Use the `report` skill for OpenCode bug reports.
