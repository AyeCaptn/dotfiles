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
  -e 'if (count of Finder windows) is 0 then' \
  -e 'set newWindow to make new Finder window' \
  -e 'set target of newWindow to (path to downloads folder)' \
  -e 'end if' \
  -e 'activate' \
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

# Use 55% on smaller displays, capped near 1200x800 points on large displays.
# A 100x100 grid keeps the sizing display-relative while allowing the caps to
# be approximated without relying on global multi-display coordinates.
display=$(yabai -m query --spaces display --space "$current_space" | jq -er '.display') || exit 1
display_frame=$(yabai -m query --displays frame --display "$display") || exit 1
grid=$(printf '%s' "$display_frame" | jq -er '
  .frame as $f |
  ([0.55, (1200 / $f.w)] | min | . * 100 | round) as $w |
  ([0.55, (800 / $f.h)] | min | . * 100 | round) as $h |
  ((100 - $w) / 2 | floor) as $x |
  ((100 - $h) / 2 | floor) as $y |
  "100:100:\($x):\($y):\($w):\($h)"
') || exit 1
yabai -m window "$window_id" --grid "$grid" 2>/dev/null || exit 1
yabai -m window "$window_id" --focus 2>/dev/null
