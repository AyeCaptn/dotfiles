#!/usr/bin/env sh

# Keep the desktop predictable across restarts.
DESIRED_SPACES=6

for idx in $(yabai -m query --spaces | jq '.[].index | select(. > '"$DESIRED_SPACES"')' | sort -rn); do
  yabai -m space --destroy "$idx"
done

CURRENT_SPACES=$(yabai -m query --spaces | jq 'length')
for i in $(seq $((CURRENT_SPACES + 1)) $DESIRED_SPACES); do
  yabai -m space --create
done

yabai -m space 1 --label terminal
yabai -m space 2 --label browser
yabai -m space 3 --label comms
yabai -m space 4 --label notes
yabai -m space 5 --label media
yabai -m space 6 --label calendar
