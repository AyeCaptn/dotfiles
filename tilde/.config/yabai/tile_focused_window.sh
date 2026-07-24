#!/usr/bin/env sh

focused_window=$(yabai -m query --windows --window)

if [ "$(printf '%s' "$focused_window" | jq -r '."is-floating"')" = "true" ]; then
  yabai -m window "$(printf '%s' "$focused_window" | jq -r '.id')" --toggle float
fi
