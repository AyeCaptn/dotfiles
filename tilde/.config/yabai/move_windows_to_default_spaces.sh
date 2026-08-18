#!/usr/bin/env sh

yabai -m query --windows id,app,subrole,is-floating,has-ax-reference | jq -r '
  .[] | select(."has-ax-reference" and (."is-floating" | not) and .subrole == "AXStandardWindow")
  | [.id, .app] | @tsv
' |
while IFS=$(printf '\t') read -r id app; do
  space=$("$HOME/.config/yabai/default_space_for_app.sh" "$app") || continue

  yabai -m window "$id" --space "$space" 2>/dev/null
done
