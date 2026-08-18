#!/usr/bin/env sh

# Space creation and destruction require the scripting addition. Keep full SIP
# enabled and label the nine Spaces created in Mission Control instead.
attempt=0
while [ "$attempt" -lt 30 ]; do
  first_space=$(yabai -m query --spaces index --space 1 2>/dev/null | jq -er '.index == 1' 2>/dev/null) || first_space=false
  ninth_space=$(yabai -m query --spaces index --space 9 2>/dev/null | jq -er '.index == 9' 2>/dev/null) || ninth_space=false
  [ "$first_space" = true ] && [ "$ninth_space" = true ] && break
  sleep 0.1
  attempt=$((attempt + 1))
done

if [ "$first_space" != true ] || [ "$ninth_space" != true ]; then
  printf 'yabai: expected 9 Spaces, but Spaces 1 and 9 were not both available\n' >&2
  exit 1
fi

if yabai -m query --spaces index --space 10 2>/dev/null | jq -e '.index == 10' >/dev/null 2>&1; then
  printf 'yabai: expected exactly 9 Spaces, but additional Spaces exist\n' >&2
fi

# Clear labels first so reordered Spaces cannot leave duplicate names behind.
for index in 1 2 3 4 5 6 7 8 9; do
  yabai -m space "$index" --label 2>/dev/null
done

yabai -m space 1 --label terminal
yabai -m space 2 --label web
yabai -m space 3 --label comms
yabai -m space 4 --label notes
yabai -m space 5 --label media
yabai -m space 6 --label calendar
yabai -m space 7 --label development
yabai -m space 8 --label creative
yabai -m space 9 --label office

# The terminal benefits from denser spacing than other workspaces.
yabai -m config --space terminal top_padding 10
yabai -m config --space terminal bottom_padding 6
yabai -m config --space terminal left_padding 6
yabai -m config --space terminal right_padding 6
yabai -m config --space terminal window_gap 6
