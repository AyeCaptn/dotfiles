#!/usr/bin/env sh

# Start only the two essential apps. route_first_window.sh handles placement
# for apps launched later in the session.

launch_once() {
  app_name="$1"

  if ! yabai -m query --windows app | jq -e --arg app "$app_name" 'any(.[]; .app == $app)' >/dev/null; then
    open -a "$app_name"
  fi
}

launch_once "Ghostty"
launch_once "Zen"
