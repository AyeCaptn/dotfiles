#!/usr/bin/env sh

# omniwmctl watch sends one event on stdin. It is a state notification; the
# SketchyBar module performs one fresh coalesced query for both focus and apps.
cat >/dev/null
sketchybar --trigger workspace_update --trigger windows_on_spaces 2>/dev/null || true
