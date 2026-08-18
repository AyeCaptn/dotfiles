#!/usr/bin/env sh

home_space="$1"
shift

for candidate in "$@"; do
  if open -Ra "$candidate" 2>/dev/null; then
    app="$candidate"
    break
  fi
done
[ -n "${app:-}" ] || exit 1

target_space=$(yabai -m query --spaces index --space "$home_space" 2>/dev/null | jq -r '.index') || exit 1
windows=$(yabai -m query --windows id,app,space,subrole,is-floating,has-ax-reference 2>/dev/null) || exit 1

window_id=$(printf '%s' "$windows" | jq -er --arg app "$app" --argjson space "$target_space" '
  first(.[] | select(
    .space == $space and
    ."has-ax-reference" and (."is-floating" | not) and .subrole == "AXStandardWindow" and
    (.app == $app or (.app | endswith($app)) or ($app == "Microsoft Teams" and .app == "MSTeams"))
  )) | .id
' 2>/dev/null)
if [ -n "$window_id" ] && yabai -m window "$window_id" --focus 2>/dev/null; then
  exit
fi

# If its only window was moved manually, restore that window instead of
# creating another one.
window_id=$(printf '%s' "$windows" | jq -er --arg app "$app" '
  first(.[] | select(
    ."has-ax-reference" and (."is-floating" | not) and .subrole == "AXStandardWindow" and
    (.app == $app or (.app | endswith($app)) or ($app == "Microsoft Teams" and .app == "MSTeams"))
  )) | .id
' 2>/dev/null)
if [ -n "$window_id" ] && yabai -m window "$window_id" --space "$home_space" 2>/dev/null; then
  yabai -m window "$window_id" --focus 2>/dev/null
  exit
fi

yabai -m space --focus "$home_space" 2>/dev/null
open -a "$app" || exit 1

# Existing inaccessible windows can become controllable only after activation;
# newly launched apps also need a moment to create their first window.
attempt=0
while [ "$attempt" -lt 30 ]; do
  windows=$(yabai -m query --windows id,app,space,subrole,is-floating,has-ax-reference 2>/dev/null) || exit 1
  window_id=$(printf '%s' "$windows" | jq -er --arg app "$app" --argjson space "$target_space" '
    first(.[] | select(
      .space == $space and
      ."has-ax-reference" and (."is-floating" | not) and .subrole == "AXStandardWindow" and
      (.app == $app or (.app | endswith($app)) or ($app == "Microsoft Teams" and .app == "MSTeams"))
    )) | .id
  ' 2>/dev/null)
  if [ -n "$window_id" ] && yabai -m window "$window_id" --focus 2>/dev/null; then
    exit
  fi

  window_id=$(printf '%s' "$windows" | jq -er --arg app "$app" '
    first(.[] | select(
      ."has-ax-reference" and (."is-floating" | not) and .subrole == "AXStandardWindow" and
      (.app == $app or (.app | endswith($app)) or ($app == "Microsoft Teams" and .app == "MSTeams"))
    )) | .id
  ' 2>/dev/null)
  if [ -n "$window_id" ] && yabai -m window "$window_id" --space "$home_space" 2>/dev/null; then
    yabai -m window "$window_id" --focus 2>/dev/null
    exit
  fi

  sleep 0.1
  attempt=$((attempt + 1))
done

exit 1
