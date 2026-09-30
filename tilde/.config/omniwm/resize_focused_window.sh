#!/usr/bin/env sh

set -eu

ratio="${1:-0.60}"
max_width="${2:-0}"
max_height="${3:-0}"
case "$ratio" in
  0.[1-9]|0.[1-9][0-9]) ;;
  *) printf 'usage: resize_focused_window.sh 0.NN [max-width max-height]\n' >&2; exit 2 ;;
esac
case "$max_width:$max_height" in
  *[!0-9:]*|:*|*:) printf 'usage: resize_focused_window.sh 0.NN [max-width max-height]\n' >&2; exit 2 ;;
esac

window=$(omniwmctl query focused-window 2>/dev/null)
pid=$(printf '%s' "$window" | jq -er '.result.payload.window.pid')
current=$(omniwmctl query displays --current --fields frame,visible-frame)
main=$(omniwmctl query displays --main --fields frame)

geometry=$(printf '%s\n%s' "$current" "$main" | jq -sr \
  --argjson ratio "$ratio" \
  --argjson maxWidth "$max_width" \
  --argjson maxHeight "$max_height" '
  .[0].result.payload.displays[0].visibleFrame as $v |
  .[1].result.payload.displays[0].frame as $m |
  ($v.width * $ratio |
    if $maxWidth > 0 and . > $maxWidth then $maxWidth else . end |
    round) as $w |
  ($v.height * $ratio |
    if $maxHeight > 0 and . > $maxHeight then $maxHeight else . end |
    round) as $h |
  ($v.x + (($v.width - $w) / 2) | round) as $x |
  ($m.y + $m.height - ($v.y + (($v.height - $h) / 2) + $h) | round) as $y |
  [$x, $y, $w, $h] | @tsv
')

IFS="$(printf '\t')" read -r x y width height <<EOF
$geometry
EOF

helper="$HOME/.local/bin/omniwm-set-frame"
if [ ! -x "$helper" ] \
  || [ "$HOME/.config/omniwm/set_window_frame.swift" -nt "$helper" ]; then
  "$HOME/.config/omniwm/build_set_window_frame.sh"
fi

"$helper" "$pid" "$x" "$y" "$width" "$height"
sketchybar --trigger window_state_update 2>/dev/null || true
