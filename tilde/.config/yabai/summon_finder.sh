#!/usr/bin/env sh

current_space=$(yabai -m query --spaces index --space | jq -er '.index') || exit 1

find_finder_window() {
  yabai -m query --windows id,app,subrole,has-ax-reference 2>/dev/null | jq -er '
    [.[] | select(
      .app == "Finder" and ."has-ax-reference" and
      .subrole == "AXStandardWindow"
    )]
    | (sort_by(.id) | first | .id) // empty
  ' 2>/dev/null
}

window_id=$(find_finder_window)

if [ -n "$window_id" ]; then
  yabai -m window "$window_id" --space "$current_space" 2>/dev/null || true
fi

osascript \
  -e 'tell application "Finder"' \
  -e 'activate' \
  -e 'if (count of Finder windows) is 0 then make new Finder window' \
  -e 'end tell' >/dev/null || exit 1

attempt=0
while [ -z "$window_id" ] && [ "$attempt" -lt 30 ]; do
  sleep 0.1
  window_id=$(find_finder_window)
  attempt=$((attempt + 1))
done
[ -n "$window_id" ] || exit 1

yabai -m window "$window_id" --space "$current_space" 2>/dev/null || true
is_floating=$(yabai -m query --windows is-floating --window "$window_id" | jq -r '."is-floating"')
if [ "$is_floating" != "true" ]; then
  yabai -m window "$window_id" --toggle float 2>/dev/null || exit 1
fi
yabai -m window "$window_id" --grid 5:14:3:1:8:3 2>/dev/null || exit 1
yabai -m window "$window_id" --focus 2>/dev/null
