#!/usr/bin/env sh

# Permanent rules describe window behavior. Startup placement uses one-shot
# rules so later windows open on the current space.

for label in \
  mail_compose_float \
  mail_utility_float \
  common_modal_float \
  common_utility_float \
  system_settings_float \
  system_information_float \
  activity_monitor_float \
  calculator_float \
  finder_utility_float \
  ghostty_main_terminal \
  onepassword_float \
  tailscale_float \
  cisco_anyconnect_float \
  system_dialog_float; do
  yabai -m rule --remove "$label" 2>/dev/null
done

# Mail compose and utility windows should float instead of changing layout.
yabai -m rule --add label="mail_compose_float" app="^Mail$" title="^(New Message|Message|Re:|Fwd:)" manage=off
yabai -m rule --add label="mail_utility_float" app="^Mail$" title="^(Preferences|Settings|Rules|Signatures)" manage=off

# Browser/application utility windows.
yabai -m rule --add label="common_modal_float" title="^(Preferences|Settings|About|Open|Save|Print)$" manage=off
yabai -m rule --add label="common_utility_float" title="^(Downloads|Developer Tools|Picture in Picture)$" manage=off

# Keep system utility windows usable.
yabai -m rule --add label="system_settings_float" app="^System Settings$" manage=off
yabai -m rule --add label="system_information_float" app="^System Information$" manage=off
yabai -m rule --add label="activity_monitor_float" app="^Activity Monitor$" manage=off
yabai -m rule --add label="calculator_float" app="^Calculator$" manage=off
yabai -m rule --add label="finder_utility_float" app="^Finder$" title="^(Copy|Move|Info|Preferences)" manage=off
yabai -m rule --add label="onepassword_float" app="^1Password$" manage=off
yabai -m rule --add label="tailscale_float" app="^Tailscale$" manage=off
yabai -m rule --add label="cisco_anyconnect_float" app="^Cisco AnyConnect Secure Mobility Client$" manage=off
yabai -m rule --add label="system_dialog_float" subrole="^AXSystemDialog$" manage=off
