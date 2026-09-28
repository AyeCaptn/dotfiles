#!/usr/bin/env sh

set -eu

workspace="${1:?workspace number or name required}"
if pgrep -x OmniWM >/dev/null 2>&1 && omniwmctl ping >/dev/null 2>&1; then
  omniwmctl workspace focus-name "$workspace" >/dev/null
else
  "$HOME/.config/yabai/focus_space.sh" "$workspace"
fi
