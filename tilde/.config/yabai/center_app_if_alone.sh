#!/usr/bin/env sh

window_id="${1:-${YABAI_WINDOW_ID:-}}"
[ -n "$window_id" ] || exit 0

window=$(yabai -m query --windows --window "$window_id" 2>/dev/null) || exit 0
space=$(printf '%s' "$window" | jq -er '.space') || exit 0

# Hidden and minimized windows do not make the workspace visually occupied.
yabai -m query --windows 2>/dev/null | jq -e \
  --argjson id "$window_id" \
  --argjson space "$space" '
    any(.[];
      .id != $id and
      .space == $space and
      ."has-ax-reference" and
      (."is-hidden" | not) and
      (."is-minimized" | not)
    )
  ' >/dev/null && exit 0

yabai -m window "$window_id" --grid 5:7:2:1:3:3
