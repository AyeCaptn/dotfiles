#!/usr/bin/env sh

while pgrep -x OmniWM >/dev/null 2>&1; do
  if omniwmctl ping >/dev/null 2>&1; then
    exec omniwmctl watch workspace-bar --reconnect \
      --exec "$HOME/.config/omniwm/sketchybar_refresh.sh"
  fi
  sleep 1
done
