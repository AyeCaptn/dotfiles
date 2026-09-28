#!/usr/bin/env sh

set -eu

workspace="${1:?workspace required}"
shift
[ "$#" -gt 0 ] || exit 2

windows=$(omniwmctl query windows --fields id,app 2>/dev/null || printf '{}')
for app in "$@"; do
  window_id=$(printf '%s' "$windows" | jq -r --arg app "$app" \
    '.result.payload.windows[]? | select(.app.name == $app) | .id' | head -n 1)
  if [ -n "$window_id" ] && omniwmctl window navigate "$window_id" >/dev/null 2>&1; then
    exit 0
  fi
done

"$HOME/.config/omniwm/focus_workspace.sh" "$workspace"
for app in "$@"; do
  if open -Ra "$app" >/dev/null 2>&1; then
    open -a "$app"
    exit 0
  fi
done

printf 'OmniWM: none of these applications is installed: %s\n' "$*" >&2
exit 1
