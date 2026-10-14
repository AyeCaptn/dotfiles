#!/usr/bin/env sh

set -eu

omniwmctl query windows --fields id | jq -r '.result.payload.windows[]?.id' |
while IFS= read -r window_id; do
  [ -z "$window_id" ] || omniwmctl rule apply --window "$window_id" >/dev/null 2>&1 || true
done
