#!/usr/bin/env sh

yabai -m config layout bsp
yabai -m config split_type auto
yabai -m config window_placement second_child
yabai -m config window_insertion_point focused
yabai -m config window_zoom_persist on
yabai -m config auto_balance off
yabai -m config split_ratio 0.50

# SketchyBar is shown on every display. Its 38-point notched-display height,
# combined with top padding, puts tiled windows at y=43.
yabai -m config external_bar all:33:0

yabai -m config top_padding 10
yabai -m config bottom_padding 10
yabai -m config left_padding 10
yabai -m config right_padding 10
yabai -m config window_gap 8

yabai -m config mouse_follows_focus off
yabai -m config focus_follows_mouse off
yabai -m config mouse_modifier alt
yabai -m config mouse_action1 move
yabai -m config mouse_action2 resize
yabai -m config mouse_drop_action swap

# Keep the active-window treatment in JankyBorders. Frame animations and
# opacity require a scripting addition, while this setup intentionally keeps
# full SIP enabled. JankyBorders supports them if that policy changes later.
yabai -m config window_opacity off
yabai -m config window_animation_duration 0.0
yabai -m config skip_window_focus_animation on
yabai -m config insert_feedback_color 0xffc6a0f6
