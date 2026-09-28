#!/usr/bin/env sh

set -eu

window=$(omniwmctl query focused-window 2>/dev/null)
window_id=$(printf '%s' "$window" | jq -er '.result.payload.window.id')
app=$(printf '%s' "$window" | jq -er '.result.payload.window.app.name')
semantic=$("$HOME/.config/yabai/default_space_for_app.sh" "$app") || exit 0
workspace=$("$HOME/.config/omniwm/workspace_number.sh" "$semantic")

omniwmctl window move-to-workspace "$window_id" "$workspace" >/dev/null
omniwmctl workspace focus-name "$workspace" >/dev/null
