#!/usr/bin/env sh

window_id="${1:-${YABAI_WINDOW_ID:-}}"
[ -n "$window_id" ] || exit 0

windows=$(yabai -m query --windows id,app,space,subrole,is-floating,has-ax-reference 2>/dev/null) || exit 0
window=$(printf '%s' "$windows" | jq -cer --argjson id "$window_id" '.[] | select(.id == $id)') || exit 0
app=$(printf '%s' "$window" | jq -r '.app')
home_space=$("$HOME/.config/yabai/default_space_for_app.sh" "$app") || exit 0

# Floating dialogs and utility windows stay where they were opened.
printf '%s' "$window" | jq -e '
  ."has-ax-reference" and
  (."is-floating" | not) and
  .subrole == "AXStandardWindow"
' >/dev/null || exit 0

target_space=$(yabai -m query --spaces index --space "$home_space" 2>/dev/null | jq -r '.index') || exit 0

# Multiple window-created events converge on one home window. Once that home
# exists, later windows intentionally remain on the current space.
printf '%s' "$windows" | jq -e --arg app "$app" --argjson space "$target_space" '
  any(.[]; .app == $app and .space == $space and ."has-ax-reference" and
    (."is-floating" | not) and .subrole == "AXStandardWindow")
' >/dev/null && exit 0

home_window=$(printf '%s' "$windows" | jq -er --arg app "$app" '
  [.[] | select(.app == $app and ."has-ax-reference" and
    (."is-floating" | not) and .subrole == "AXStandardWindow")]
  | sort_by(.id) | first | .id
') || exit 0
yabai -m window "$home_window" --space "$home_space" 2>/dev/null
