---
name: Remote preview
description: Create and share screenshots, rendered UI previews, diagrams, and other visual artifacts from this Mac when the user is connected remotely or the OpenCode Review pane is unavailable
---

# Remote preview workflow

Use this skill when the user asks to see or review a visual result while working remotely, especially when no OpenCode desktop browser is connected.

## Preferred delivery order

1. Create the requested artifact in the approved temporary tree under `$TMPDIR/opencode`. Do not add review-only output to the repository.
2. If the OpenCode desktop browser is connected, use `browser.preview` with the artifact path.
3. Otherwise publish it to this Mac's tailnet with `scripts/remote-preview publish <file>` and give the user the printed HTTPS URL.
4. Keep the server available while the user reviews the result. When the user is done, run `scripts/remote-preview stop`.

## Screenshots and faithful renders

- For a real macOS screenshot, first check permission with:

  ```sh
  swift -e 'import CoreGraphics; print(CGPreflightScreenCaptureAccess())'
  ```

- When permission is available, use `/usr/sbin/screencapture -x` and crop to the relevant area rather than exposing the whole desktop.
- When Screen Recording permission is unavailable, do not call a reconstruction a screenshot. Build a clearly labeled faithful render from live application state, geometry, colors, and values.
- SVG is convenient for UI renders. Convert it to PNG with `rsvg-convert` so it is easy to review remotely.
- Read the finished image locally before publishing it. Check proportions, clipping, alignment, text, current values, and whether the render actually illustrates the requested change.
- Avoid capturing or publishing unrelated windows, notifications, credentials, personal data, or secrets.

## Tailnet publishing on this machine

The helper serves exactly one isolated directory through two local components:

- Python HTTP server: `127.0.0.1:8766`
- Tailscale Serve: tailnet-only HTTPS on port `8443`

It preserves the existing OpenCode TCP service on tailnet port `4096`. Never use Tailscale Funnel, bind the Python server to `0.0.0.0`, or serve a repository/workspace directory.

The helper copies only the selected artifact into `$TMPDIR/opencode/remote-preview/public`, starts or reuses the local server, configures the port-specific Tailscale route, and prints a cache-busted URL. `stop` removes only the `8443` route and the helper-owned Python process.

## Reporting

- Say whether the artifact is a native screenshot or a rendered preview.
- Include the tailnet URL as a Markdown link.
- Mention that the URL is temporary and can be removed after review.
- If publishing fails, report the local artifact path and the failing layer (render, local HTTP, or Tailscale) instead of weakening network restrictions.
