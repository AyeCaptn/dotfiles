#!/usr/bin/env sh

yabai -m query --windows | jq -r '.[] | [.id, .app] | @tsv' |
while IFS=$(printf '\t') read -r id app; do
  case "$app" in
    Ghostty) space=terminal ;;
    Zen) space=browser ;;
    Mail|"Microsoft Outlook"|*WhatsApp*|MSTeams|"Microsoft Teams") space=comms ;;
    Obsidian|Notes) space=notes ;;
    Spotify) space=media ;;
    Calendar) space=calendar ;;
    *) continue ;;
  esac

  yabai -m window "$id" --space "$space"
done
