#!/usr/bin/env sh

# Refresh SketchyBar when the window/workspace state changes.
for label in \
  sketchybar_space_change \
  sketchybar_window_focus \
  sketchybar_window_created \
  sketchybar_window_destroyed \
  sketchybar_window_moved \
  center_cisco_anyconnect \
  display_added_setup \
  display_removed_setup \
  system_woke_display_setup; do
  yabai -m signal --remove "$label" 2>/dev/null
done

yabai -m signal --add label="sketchybar_space_change" event=space_changed action="sketchybar --trigger space_change 2>/dev/null"
yabai -m signal --add label="sketchybar_window_focus" event=window_focused action="sketchybar --trigger window_focus 2>/dev/null"
yabai -m signal --add label="sketchybar_window_created" event=window_created action="sketchybar --trigger windows_on_spaces 2>/dev/null"
yabai -m signal --add label="sketchybar_window_destroyed" event=window_destroyed action="sketchybar --trigger windows_on_spaces 2>/dev/null"
yabai -m signal --add label="sketchybar_window_moved" event=window_moved action="sketchybar --trigger windows_on_spaces 2>/dev/null"
yabai -m signal --add label="center_cisco_anyconnect" event=window_created app="^Cisco AnyConnect Secure Mobility Client$" action="$HOME/.config/yabai/center_cisco_anyconnect.sh"

yabai -m signal --add label="display_added_setup" event=display_added action="$HOME/.config/yabai/display_setup.sh"
yabai -m signal --add label="display_removed_setup" event=display_removed action="$HOME/.config/yabai/display_setup.sh"
yabai -m signal --add label="system_woke_display_setup" event=system_woke action="$HOME/.config/yabai/display_setup.sh"
