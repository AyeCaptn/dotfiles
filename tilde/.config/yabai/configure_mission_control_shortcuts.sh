#!/usr/bin/env sh

set -eu

# Keep the macOS Desktop settings required by current asmvik/yabai releases.
restart_finder=false
restart_dock=false
if [ "$(defaults read com.apple.finder CreateDesktop 2>/dev/null || true)" != 1 ]; then
  defaults write com.apple.finder CreateDesktop -bool true
  restart_finder=true
fi
if [ "$(defaults read com.apple.WindowManager EnableStandardClickToShowDesktop 2>/dev/null || true)" != 0 ]; then
  defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
  restart_dock=true
fi

# yabai 7.1.25's SIP-clean space focus bridge is a no-op on macOS 27. Assign
# Control+1…9 as a native fallback for empty Desktops; focus_space.sh normally
# takes yabai's faster application-activation path instead.
domain=com.apple.symbolichotkeys
tmp=$(mktemp "${TMPDIR:-/tmp}/symbolichotkeys.XXXXXX.plist")
trap 'rm -f "$tmp"' EXIT INT TERM

defaults export "$domain" "$tmp" >/dev/null
changed=false

set_shortcut() {
  id="$1"
  keycode="$2"
  path="AppleSymbolicHotKeys.$id"

  enabled=$(plutil -extract "$path.enabled" raw -o - "$tmp" 2>/dev/null || true)
  stored_keycode=$(plutil -extract "$path.value.parameters.1" raw -o - "$tmp" 2>/dev/null || true)
  modifiers=$(plutil -extract "$path.value.parameters.2" raw -o - "$tmp" 2>/dev/null || true)
  if [ "$enabled" = true ] && [ "$stored_keycode" = "$keycode" ] \
    && [ "$modifiers" = 262144 ]; then
    return
  fi

  plutil -remove "$path" "$tmp" >/dev/null 2>&1 || true
  plutil -insert "$path" -json \
    "{\"enabled\":true,\"value\":{\"parameters\":[65535,$keycode,262144],\"type\":\"standard\"}}" \
    "$tmp"
  changed=true
}

# Mission Control symbolic hotkeys 118…126 are Desktop 1…9. Key codes follow
# the physical number row rather than numeric order after 4.
set_shortcut 118 18
set_shortcut 119 19
set_shortcut 120 20
set_shortcut 121 21
set_shortcut 122 23
set_shortcut 123 22
set_shortcut 124 26
set_shortcut 125 28
set_shortcut 126 25

if [ "$changed" = true ]; then
  defaults import "$domain" "$tmp" >/dev/null
  killall cfprefsd >/dev/null 2>&1 || true
  restart_dock=true
  killall SystemUIServer >/dev/null 2>&1 || true
fi

[ "$restart_finder" = false ] || killall Finder >/dev/null 2>&1 || true
[ "$restart_dock" = false ] || killall Dock >/dev/null 2>&1 || true
