#!/usr/bin/env sh

target_space=$(yabai -m query --spaces --space | jq -r '.index')
existing_windows=$(yabai -m query --windows | jq -r '.[] | select(.app == "Zen") | .id')
"$HOME/.config/yabai/tile_focused_window.sh"

/Applications/Zen.app/Contents/MacOS/zen --new-window >/dev/null 2>&1 &

attempt=0
while [ "$attempt" -lt 50 ]; do
  new_window=$(yabai -m query --windows | jq -r --arg existing "$existing_windows" '
    ($existing | split("\n") | map(select(length > 0) | tonumber)) as $ids
    | .[] | select(.app == "Zen" and ([.id] - $ids | length > 0)) | .id
  ' | tail -n 1)

  if [ -n "$new_window" ]; then
    yabai -m window "$new_window" --space "$target_space"
    yabai -m space --focus "$target_space"
    yabai -m window "$new_window" --focus
    exit 0
  fi

  sleep 0.1
  attempt=$((attempt + 1))
done

exit 1
