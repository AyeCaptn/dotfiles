#!/usr/bin/env sh

app=$(yabai -m query --windows --window | jq -r '.app')
space=$("$HOME/.config/yabai/default_space_for_app.sh" "$app") || exit 0

"$HOME/.config/yabai/move_window_to_space.sh" "$space"
