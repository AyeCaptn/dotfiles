#!/usr/bin/env sh

set -eu

window=$(omniwmctl query focused-window 2>/dev/null)
app=$(printf '%s' "$window" | jq -r '.result.payload.window.app.name // empty')

if [ "$app" = "Finder" ]; then
  osascript -e 'tell application "Finder" to set visible to false' >/dev/null
else
  omniwmctl command close-focused-window >/dev/null
fi
