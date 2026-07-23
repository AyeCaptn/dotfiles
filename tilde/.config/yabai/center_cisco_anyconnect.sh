#!/usr/bin/env sh

# The window is unmanaged by its rule, then placed centrally on its own space.
yabai -m window "$YABAI_WINDOW_ID" --grid 5:7:2:1:3:3
