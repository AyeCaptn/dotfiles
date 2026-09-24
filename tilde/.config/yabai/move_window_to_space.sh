#!/usr/bin/env sh

set -eu

selector="${1:?space selector required}"
window_id=$(yabai -m query --windows id --window | jq -er '.id')

yabai -m window "$window_id" --space "$selector"
"$HOME/.config/yabai/focus_space.sh" "$selector" "$window_id"
