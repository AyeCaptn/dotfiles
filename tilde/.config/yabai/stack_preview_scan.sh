#!/usr/bin/env sh

window_id="${1:-${YABAI_WINDOW_ID:-}}"
[ -n "$window_id" ] || exit 0

# Preview may still be initializing the window when window_created fires.
sleep 0.1
windows=$(yabai -m query --windows id,app,title,space,subrole,is-floating,has-ax-reference 2>/dev/null) || exit 0
window=$(printf '%s' "$windows" | jq -cer --argjson id "$window_id" '.[] | select(.id == $id)') || exit 0

printf '%s' "$window" | jq -e '
  .app == "Preview" and
  (.title | startswith("Import from ") | not) and
  ."has-ax-reference" and
  (."is-floating" | not) and
  .subrole == "AXStandardWindow"
' >/dev/null || exit 0

space=$(printf '%s' "$window" | jq -r '.space')

# Only stack Preview documents while its scanner window is open on this Space.
printf '%s' "$windows" | jq -e --argjson space "$space" '
  any(.[]; .app == "Preview" and .space == $space and
    (.title | startswith("Import from ")))
' >/dev/null || exit 0

target=$(printf '%s' "$windows" | jq -er --argjson id "$window_id" --argjson space "$space" '
  [.[] | select(.id != $id and .app == "Preview" and .space == $space and
    (.title | startswith("Import from ") | not) and
    ."has-ax-reference" and (."is-floating" | not) and
    .subrole == "AXStandardWindow")]
  | sort_by(.id) | first | .id
') || exit 0

yabai -m window "$target" --stack "$window_id" 2>/dev/null
