#!/usr/bin/env sh

# Refresh SketchyBar when the window/workspace state changes.
for label in \
  sketchybar_space_change \
  sketchybar_window_focus \
  sketchybar_window_created \
  sketchybar_window_destroyed \
  focus_window_after_destroy \
  sketchybar_window_moved \
  center_cisco_anyconnect \
  display_added_setup \
  display_removed_setup \
  system_woke_display_setup; do
  yabai -m signal --remove "$label" 2>/dev/null
done

yabai -m signal --add label="sketchybar_window_created" event=window_created action="sketchybar --trigger windows_on_spaces 2>/dev/null"
yabai -m signal --add label="sketchybar_window_destroyed" event=window_destroyed action="sketchybar --trigger windows_on_spaces 2>/dev/null"
# macOS can leave a space unfocused after a close/quit; restore the last window only then.
yabai -m signal --add label="focus_window_after_destroy" event=window_destroyed action='sleep 0.1; yabai -m query --windows --space | jq -e "any(.[]; .\"has-focus\")" >/dev/null || yabai -m window --focus recent'
yabai -m signal --add label="sketchybar_window_moved" event=window_moved action="sketchybar --trigger windows_on_spaces 2>/dev/null"
yabai -m signal --add label="center_cisco_anyconnect" event=window_created app="^Cisco AnyConnect Secure Mobility Client$" action="$HOME/.config/yabai/center_cisco_anyconnect.sh"

yabai -m signal --add label="display_added_setup" event=display_added action="$HOME/.config/yabai/display_setup.sh"
yabai -m signal --add label="display_removed_setup" event=display_removed action="$HOME/.config/yabai/display_setup.sh"
yabai -m signal --add label="system_woke_display_setup" event=system_woke action="$HOME/.config/yabai/display_setup.sh"
