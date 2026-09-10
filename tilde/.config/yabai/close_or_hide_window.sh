#!/usr/bin/env sh

app=$(yabai -m query --windows app --window 2>/dev/null | jq -r '.app // empty')

if [ "$app" = "Finder" ]; then
  osascript -e 'tell application "Finder" to set visible to false' >/dev/null
  exit
fi

yabai -m window --close
