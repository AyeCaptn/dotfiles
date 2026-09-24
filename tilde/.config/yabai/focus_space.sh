#!/usr/bin/env sh

set -eu

selector="${1:?space selector required}"
preferred_window="${2:-}"
space=$(yabai -m query --spaces id,index,display,is-visible --space "$selector")
index=$(printf '%s' "$space" | jq -er '.index')
display=$(printf '%s' "$space" | jq -er '.display')
visible=$(printf '%s' "$space" | jq -r '."is-visible"')

# A Desktop already shown on another display only needs that display focused.
if [ "$visible" = true ]; then
  yabai -m display --focus "$display" 2>/dev/null || true
  exit 0
fi

# macOS 27 requires a serialized IOHID payload on synthetic Dock swipes. The
# local helper emits that high-velocity gesture, reproducing the animationless
# technique used by current BetterTouchTool releases without installing BTT.
instant_switcher="$HOME/.local/bin/yabai-space-switch"
mouse_display=$(yabai -m query --displays index --display mouse 2>/dev/null | jq -r '.index' || true)
if [ -x "$instant_switcher" ] && [ "$mouse_display" = "$display" ]; then
  positions=$(yabai -m query --spaces index,is-visible --display "$display" 2>/dev/null || true)
  current_position=$(printf '%s' "$positions" | jq -er '
    to_entries | first(.[] | select(.value."is-visible")).key + 1
  ' 2>/dev/null || true)
  target_position=$(printf '%s' "$positions" | jq -er --argjson index "$index" '
    to_entries | first(.[] | select(.value.index == $index)).key + 1
  ' 2>/dev/null || true)
  if [ -n "$current_position" ] && [ -n "$target_position" ]; then
    if [ "$current_position" -lt "$target_position" ]; then
      direction=right
      steps=$((target_position - current_position))
    else
      direction=left
      steps=$((current_position - target_position))
    fi
    if [ "$steps" -gt 0 ] && "$instant_switcher" "$direction" "$steps" 2>/dev/null; then
      exit 0
    fi
  fi
fi

# With full SIP, macOS 27 ignores yabai's direct space-focus request. yabai can
# still bypass the native animation when an application/window on that space is
# activated (`skip_window_focus_animation on`). This is also the normal path
# after moving a window, because the destination can no longer be empty.
window=
if [ -n "$preferred_window" ]; then
  window=$(yabai -m query --windows id,pid,space,has-ax-reference,is-minimized,is-hidden --window "$preferred_window" 2>/dev/null \
    | jq -er --argjson space "$index" 'select(
      .space == $space and
      ."has-ax-reference" and
      (."is-minimized" | not) and
      (."is-hidden" | not)
    ) | [.id, .pid] | @tsv' 2>/dev/null || true)
fi
if [ -z "$window" ]; then
  window=$(yabai -m query --windows id,pid,has-ax-reference,is-minimized,is-hidden --space "$index" 2>/dev/null \
    | jq -er 'first(.[] | select(
      ."has-ax-reference" and
      (."is-minimized" | not) and
      (."is-hidden" | not)
    )) | [.id, .pid] | @tsv' 2>/dev/null || true)
fi
if [ -n "$window" ]; then
  window_id=$(printf '%s' "$window" | cut -f1)
  process_id=$(printf '%s' "$window" | cut -f2)
  yabai -m window "$window_id" --focus 2>/dev/null || true
  executable=$(ps -p "$process_id" -o comm= 2>/dev/null || true)
  case "$executable" in
    *.app/Contents/MacOS/*)
      application="${executable%%.app/Contents/MacOS/*}.app"
      open "$application" >/dev/null 2>&1 || true
      ;;
    *)
      osascript - "$process_id" >/dev/null 2>&1 <<'APPLESCRIPT' || true
on run argv
  tell application "System Events"
    set frontmost of first application process whose unix id is (item 1 of argv as integer) to true
  end tell
end run
APPLESCRIPT
      ;;
  esac

  attempt=0
  while [ "$attempt" -lt 20 ]; do
    visible=$(yabai -m query --spaces is-visible --space "$index" 2>/dev/null \
      | jq -r '."is-visible" // false')
    [ "$visible" = true ] && exit 0
    sleep 0.025
    attempt=$((attempt + 1))
  done
fi

case "$index" in
  1) keycode=18 ;;
  2) keycode=19 ;;
  3) keycode=20 ;;
  4) keycode=21 ;;
  5) keycode=23 ;;
  6) keycode=22 ;;
  7) keycode=26 ;;
  8) keycode=28 ;;
  9) keycode=25 ;;
  *) printf 'unsupported Desktop index: %s\n' "$index" >&2; exit 1 ;;
esac

# Prefer macOS's exact Desktop shortcut. Newly written symbolic hotkeys may not
# become live until the next login, so fall back to native left/right switching
# below when this chord does not move immediately.
osascript -e "tell application \"System Events\" to key code $keycode using control down"
attempt=0
while [ "$attempt" -lt 6 ]; do
  visible=$(yabai -m query --spaces is-visible --space "$index" 2>/dev/null \
    | jq -r '."is-visible" // false')
  [ "$visible" = true ] && exit 0
  sleep 0.05
  attempt=$((attempt + 1))
done

# Control+Left/Right acts on the focused display. Focus the target display, then
# walk its native Desktop sequence and wait for every transition to settle.
yabai -m display --focus "$display" 2>/dev/null || true
while :; do
  current=$(yabai -m query --spaces index,is-visible --display "$display" 2>/dev/null \
    | jq -er 'first(.[] | select(."is-visible")).index')
  [ "$current" = "$index" ] && exit 0

  if [ "$current" -lt "$index" ]; then
    arrow=124
  else
    arrow=123
  fi
  osascript -e "tell application \"System Events\" to key code $arrow using control down"

  attempt=0
  while [ "$attempt" -lt 40 ]; do
    next=$(yabai -m query --spaces index,is-visible --display "$display" 2>/dev/null \
      | jq -er 'first(.[] | select(."is-visible")).index')
    [ "$next" != "$current" ] && break
    sleep 0.05
    attempt=$((attempt + 1))
  done
  if [ "$next" = "$current" ]; then
    printf 'Desktop %s did not become visible\n' "$index" >&2
    exit 1
  fi
done
