#!/usr/bin/env sh

set -eu

ratio="${1:-0.60}"
mode=$(omniwmctl query windows --focused --fields mode | jq -r \
  '.result.payload.windows[0].mode // empty')

if [ "$mode" = "floating" ]; then
  omniwmctl command toggle-focused-window-floating >/dev/null
  exit 0
fi

omniwmctl command toggle-focused-window-floating >/dev/null
sleep 0.08
"$HOME/.config/omniwm/resize_focused_window.sh" "$ratio"
