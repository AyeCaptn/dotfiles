#!/usr/bin/env sh

app=$(yabai -m query --windows --window | jq -r '.app')
space=$("$HOME/.config/yabai/default_space_for_app.sh" "$app") || exit 0

yabai -m window --space "$space"
yabai -m space --focus "$space" 2>/dev/null
