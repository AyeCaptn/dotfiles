#!/usr/bin/env sh

yabai -m config layout bsp
yabai -m config window_placement second_child
yabai -m config auto_balance on
yabai -m config split_ratio 0.50

# Reserve room for SketchyBar.
yabai -m config external_bar main:33:0

yabai -m config top_padding 12
yabai -m config bottom_padding 12
yabai -m config left_padding 12
yabai -m config right_padding 12
yabai -m config window_gap 8

yabai -m config mouse_follows_focus off
yabai -m config focus_follows_mouse off
yabai -m config mouse_modifier alt
yabai -m config mouse_action1 move
yabai -m config mouse_action2 resize
yabai -m config mouse_drop_action swap

yabai -m config window_opacity off
yabai -m config window_shadow float
