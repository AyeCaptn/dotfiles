#!/usr/bin/env sh

set -eu

workspace=$(omniwmctl query workspaces --current --fields raw-name | jq -er \
  '.result.payload.workspaces[0].rawName')
focused=$(omniwmctl query focused-window | jq -r '.result.payload.window.id // empty')

omniwmctl query windows --workspace "$workspace" --fields id | jq -r \
  '.result.payload.windows[]?.id' |
while IFS= read -r window_id; do
  [ "$window_id" = "$focused" ] || omniwmctl window close "$window_id" >/dev/null 2>&1 || true
done
