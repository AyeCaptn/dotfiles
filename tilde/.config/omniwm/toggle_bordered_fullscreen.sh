#!/usr/bin/env sh

set -eu

window=$(omniwmctl query windows --focused \
  --fields id,pid,display,frame,mode 2>/dev/null)
window_id=$(printf '%s' "$window" | jq -er '.result.payload.windows[0].id')
pid=$(printf '%s' "$window" | jq -er '.result.payload.windows[0].pid')
mode=$(printf '%s' "$window" | jq -er '.result.payload.windows[0].mode')
display_id=$(printf '%s' "$window" | jq -er '.result.payload.windows[0].display.id')

helper="$HOME/.local/bin/omniwm-set-frame"
if [ ! -x "$helper" ] \
  || [ "$HOME/.config/omniwm/set_window_frame.swift" -nt "$helper" ]; then
  "$HOME/.config/omniwm/build_set_window_frame.sh"
fi

main=$(omniwmctl query displays --main --fields frame)
main_top=$(printf '%s' "$main" | jq -er \
  '.result.payload.displays[0].frame | .y + .height')

state_dir="$HOME/Library/Caches/com.sem.desktop-wm/bordered-fullscreen"
mkdir -p "$state_dir"
state_key=$(printf '%s' "$window_id" | shasum -a 256 | awk '{print $1}')
state_file="$state_dir/$state_key.json"

if [ -f "$state_file" ] \
  && [ "$(jq -r '.id // empty' "$state_file")" = "$window_id" ]; then
  original_mode=$(jq -er '.mode' "$state_file")
  if [ "$original_mode" = "tiling" ]; then
    [ "$mode" != "floating" ] \
      || omniwmctl command toggle-focused-window-floating >/dev/null
  else
    if [ "$mode" != "floating" ]; then
      omniwmctl command toggle-focused-window-floating >/dev/null
      sleep 0.08
    fi
    restore_geometry=$(jq -r --argjson mainTop "$main_top" '
      .frame as $f |
      [$f.x, ($mainTop - ($f.y + $f.height)), $f.width, $f.height] | @tsv
    ' "$state_file")
    IFS="$(printf '\t')" read -r x y width height <<EOF
$restore_geometry
EOF
    "$helper" "$pid" "$x" "$y" "$width" "$height"
  fi
  rm -f "$state_file"
  exit 0
fi

temporary="$state_file.tmp.$$"
printf '%s' "$window" | jq -e '
  .result.payload.windows[0] |
  {id, mode, frame}
' >"$temporary"
mv "$temporary" "$state_file"

if [ "$mode" != "floating" ]; then
  omniwmctl command toggle-focused-window-floating >/dev/null
  sleep 0.08
fi

display=$(omniwmctl query displays --display "$display_id" \
  --fields frame,outer-gap-left,outer-gap-right,outer-gap-top,outer-gap-bottom)
geometry=$(printf '%s' "$display" | jq -r --argjson mainTop "$main_top" '
  .result.payload.displays[0] as $d |
  ($d.frame.x + $d.outerGapLeft) as $x |
  ($d.frame.y + $d.outerGapBottom) as $bottom |
  ($d.frame.width - $d.outerGapLeft - $d.outerGapRight) as $width |
  ($d.frame.height - $d.outerGapTop - $d.outerGapBottom) as $height |
  [$x, ($mainTop - ($bottom + $height)), $width, $height] | @tsv
')
IFS="$(printf '\t')" read -r x y width height <<EOF
$geometry
EOF

"$helper" "$pid" "$x" "$y" "$width" "$height"
