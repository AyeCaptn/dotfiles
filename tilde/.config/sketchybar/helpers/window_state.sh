#!/usr/bin/env sh

set -eu

none() {
  printf '%s\n' '{"state":"none"}'
}

if ! pgrep -x OmniWM >/dev/null 2>&1 \
  || ! omniwmctl ping >/dev/null 2>&1; then
  none
  exit 0
fi

windows=$(omniwmctl query windows \
  --fields id,app,display,workspace,frame,mode,is-visible,is-focused 2>/dev/null) || {
  none
  exit 0
}
displays=$(omniwmctl query displays --fields id,frame,visible-frame 2>/dev/null) || {
  none
  exit 0
}

fullscreen_ids='[]'
state_dir="$HOME/Library/Caches/com.sem.desktop-wm/bordered-fullscreen"
if [ -d "$state_dir" ]; then
  fullscreen_ids=$(
    for state_file in "$state_dir"/*.json; do
      [ -f "$state_file" ] || continue
      jq -r '.id // empty' "$state_file" 2>/dev/null || true
    done | jq -Rsc 'split("\n") | map(select(length > 0))'
  )
fi

printf '%s\n%s\n' "$windows" "$displays" | jq -cs \
  --argjson fullscreenIds "$fullscreen_ids" '
  def close_to($a; $b): (($a - $b) | fabs) <= 8;
  def is_sixty_percent($window; $display):
    ($display.visibleFrame // $display.frame) as $visible |
    close_to($window.frame.width; ($visible.width * 0.60)) and
    close_to($window.frame.height; ($visible.height * 0.60)) and
    close_to($window.frame.x; ($visible.x + (($visible.width - $window.frame.width) / 2))) and
    close_to($window.frame.y; ($visible.y + (($visible.height - $window.frame.height) / 2)));

  .[0].result.payload.windows as $windows |
  .[1].result.payload.displays as $displays |
  [
    $windows[] |
    select(.isVisible == true) |
    . as $window |
    ($displays[] | select(.id == $window.display.id)) as $display |
    if ($fullscreenIds | index($window.id)) != null then
      {
        state: "full",
        app: ($window.app.name // "Unknown"),
        workspace: ($window.workspace.rawName // null),
        focused: ($window.isFocused == true),
        priority: 0
      }
    elif $window.mode == "floating" and is_sixty_percent($window; $display) then
      {
        state: "sixty",
        app: ($window.app.name // "Unknown"),
        workspace: ($window.workspace.rawName // null),
        focused: ($window.isFocused == true),
        priority: 1
      }
    else
      empty
    end
  ] |
  sort_by([(if .focused then 0 else 1 end), .priority, .app]) |
  (.[0] // { state: "none" }) |
  del(.focused, .priority)
'
