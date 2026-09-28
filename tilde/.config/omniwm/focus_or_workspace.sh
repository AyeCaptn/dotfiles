#!/usr/bin/env sh

set -eu

direction="${1:?left or right required}"
case "$direction" in
  left) step=-1 ;;
  right) step=1 ;;
  *) printf 'usage: focus_or_workspace.sh {left|right}\n' >&2; exit 2 ;;
esac

before=$(omniwmctl query focused-window 2>/dev/null | jq -r \
  '.result.payload.window.id // empty')
[ -n "$before" ] || exit 0

# OmniWM reports the directional action as executed even at a Dwindle edge.
# Observe the focused token briefly to distinguish a real focus move from an
# edge no-op while retaining OmniWM's native focus and animation path.
omniwmctl command focus "$direction" >/dev/null
attempt=0
while [ "$attempt" -lt 6 ]; do
  after=$(omniwmctl query focused-window 2>/dev/null | jq -r \
    '.result.payload.window.id // empty')
  [ -n "$after" ] && [ "$after" != "$before" ] && exit 0
  sleep 0.025
  attempt=$((attempt + 1))
done

workspaces=$(omniwmctl query workspaces --fields raw-name,is-current,window-counts 2>/dev/null)
current=$(printf '%s' "$workspaces" | jq -er \
  '.result.payload.workspaces[] | select(.isCurrent) | .rawName | tonumber')
target=$((current + step))
[ "$target" -ge 1 ] || exit 0

occupied=$(printf '%s' "$workspaces" | jq -r --argjson target "$target" '
  any(.result.payload.workspaces[];
    ((.rawName | tonumber?) == $target) and ((.counts.total // 0) > 0)
  )
')
[ "$occupied" = true ] || exit 0

omniwmctl command switch-workspace "$target" >/dev/null
