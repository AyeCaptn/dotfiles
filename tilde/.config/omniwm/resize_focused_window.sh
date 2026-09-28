#!/usr/bin/env sh

set -eu

ratio="${1:-0.60}"
case "$ratio" in
  0.[1-9]|0.[1-9][0-9]) ;;
  *) printf 'usage: resize_focused_window.sh 0.NN\n' >&2; exit 2 ;;
esac

window=$(omniwmctl query focused-window 2>/dev/null)
pid=$(printf '%s' "$window" | jq -er '.result.payload.window.pid')
current=$(omniwmctl query displays --current --fields frame,visible-frame)
main=$(omniwmctl query displays --main --fields frame)

geometry=$(printf '%s\n%s' "$current" "$main" | jq -sr --argjson ratio "$ratio" '
  .[0].result.payload.displays[0].visibleFrame as $v |
  .[1].result.payload.displays[0].frame as $m |
  ($v.width * $ratio | round) as $w |
  ($v.height * $ratio | round) as $h |
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
