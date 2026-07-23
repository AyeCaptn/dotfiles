#!/usr/bin/env sh

# The first window of each app starts in its default space. Later windows open
# on the space currently in use.

launch_once() {
  app_name="$1"
  target_space="$2"
  rule_label=$(printf '%s' "startup_${app_name}_${target_space}" | tr ' ' '_')

  if ! pgrep -x "$app_name" >/dev/null; then
    yabai -m rule --remove "$rule_label" 2>/dev/null
    yabai -m rule --add --one-shot label="$rule_label" app="^$app_name$" space="$target_space"
    open -a "$app_name"
  fi
}

launch_once "Zen" browser
launch_once "Microsoft Outlook" comms
launch_once "Microsoft Teams" comms
launch_once "Obsidian" notes
launch_once "Notes" notes
launch_once "Spotify" media
launch_once "Calendar" calendar
