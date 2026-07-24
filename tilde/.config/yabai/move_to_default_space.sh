#!/usr/bin/env sh

app=$(yabai -m query --windows --window | jq -r '.app')

case "$app" in
  Ghostty) space=1 ;;
  Zen) space=2 ;;
  Mail|"Microsoft Outlook"|WhatsApp|MSTeams|"Microsoft Teams") space=3 ;;
  Obsidian|Notes) space=4 ;;
  Spotify) space=5 ;;
  Calendar) space=6 ;;
  *) exit 0 ;;
esac

yabai -m window --space "$space"
yabai -m space --focus "$space"
