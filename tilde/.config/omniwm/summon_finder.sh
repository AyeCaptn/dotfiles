#!/usr/bin/env sh

set -eu

current_workspace=$(omniwmctl query workspaces --current --fields raw-name | jq -er \
  '.result.payload.workspaces[0].rawName')

find_finder_window() {
  omniwmctl query windows --bundle-id com.apple.finder --fields id,title 2>/dev/null | jq -r \
    '.result.payload.windows[]? | select(.title != "Quick Look") | .id' | head -n 1
}

window_id=$(find_finder_window)
if [ -z "$window_id" ]; then
  osascript \
    -e 'tell application "Finder"' \
    -e 'activate' \
    -e 'if (count of Finder windows) is 0 then make new Finder window' \
    -e 'end tell' >/dev/null
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    sleep 0.1
    window_id=$(find_finder_window)
    [ -z "$window_id" ] || break
  done
fi

[ -n "$window_id" ] || exit 1
omniwmctl window move-to-workspace "$window_id" "$current_workspace" >/dev/null 2>&1 || true
omniwmctl window focus "$window_id" >/dev/null

mode=$(omniwmctl query windows --window "$window_id" --fields mode | jq -r \
  '.result.payload.windows[0].mode // empty')
if [ "$mode" != "floating" ]; then
  omniwmctl command toggle-focused-window-floating >/dev/null
  sleep 0.08
fi
"$HOME/.config/omniwm/resize_focused_window.sh" 0.60
