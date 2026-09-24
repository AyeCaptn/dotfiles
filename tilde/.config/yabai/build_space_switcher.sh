#!/usr/bin/env sh

set -eu

source_file="$HOME/.config/yabai/space_switcher.swift"
target="$HOME/.local/bin/yabai-space-switch"

if [ -x "$target" ] && [ "$target" -nt "$source_file" ]; then
  exit 0
fi

mkdir -p "${target%/*}"
temporary="$target.tmp"
trap 'rm -f "$temporary"' EXIT INT TERM

xcrun swiftc -O "$source_file" -o "$temporary" -framework ApplicationServices
codesign --force --sign - --identifier com.sem.yabai-space-switch "$temporary" >/dev/null
mv "$temporary" "$target"
