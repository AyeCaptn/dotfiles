#!/usr/bin/env sh

display_count=$(yabai -m query --displays | jq 'length')

if [ "$display_count" -eq 1 ]; then
  yabai -m config top_padding 10
  yabai -m config bottom_padding 10
  yabai -m config left_padding 10
  yabai -m config right_padding 10
  yabai -m config window_gap 8
else
  yabai -m config top_padding 14
  yabai -m config bottom_padding 14
  yabai -m config left_padding 14
  yabai -m config right_padding 14
  yabai -m config window_gap 12
fi

yabai -m config external_bar main:33:0

# Terminal space gets slightly tighter gaps.
yabai -m config --space 1 top_padding 10
yabai -m config --space 1 bottom_padding 6
yabai -m config --space 1 left_padding 6
yabai -m config --space 1 right_padding 6
yabai -m config --space 1 window_gap 6
