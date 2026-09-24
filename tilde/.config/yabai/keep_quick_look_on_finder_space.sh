#!/usr/bin/env sh

window_id="${1:-${YABAI_WINDOW_ID:-}}"
[ -n "$window_id" ] || exit 0

# Finder changes Spaces after reporting that its sticky Quick Look panel focused.
sleep 0.05
windows=$(yabai -m query --windows id,app,title,space,subrole,is-hidden,is-sticky,has-ax-reference 2>/dev/null) || exit 0

quick_look=$(printf '%s' "$windows" | jq -cer --argjson id "$window_id" '
  first(.[] | select(
    .id == $id and .app == "Finder" and
    (.title == "Quick Look" or .subrole == "Quick Look")
  )) | {space, sticky: ."is-sticky"}
') || exit 0
quick_look_space=$(printf '%s' "$quick_look" | jq -r '.space')
quick_look_sticky=$(printf '%s' "$quick_look" | jq -r '.sticky')

finder_space=$(printf '%s' "$windows" | jq -er '
  first(.[] | select(
    .app == "Finder" and .subrole == "AXStandardWindow" and
    ."has-ax-reference" and (."is-hidden" | not)
  )).space
') || exit 0

if [ "$quick_look_sticky" != "true" ] && [ "$quick_look_space" != "$finder_space" ]; then
  yabai -m window "$window_id" --space "$finder_space" 2>/dev/null || exit 0
fi

current_space=$(yabai -m query --spaces index --space 2>/dev/null | jq -r '.index')
if [ "$current_space" != "$finder_space" ]; then
  "$HOME/.config/yabai/focus_space.sh" "$finder_space" 2>/dev/null
fi
