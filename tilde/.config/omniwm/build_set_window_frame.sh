#!/usr/bin/env sh

set -eu

source_file="$HOME/.config/omniwm/set_window_frame.swift"
target="$HOME/.local/bin/omniwm-set-frame"

[ -f "$source_file" ] || {
  printf 'missing source: %s\n' "$source_file" >&2
  exit 1
}

if [ -x "$target" ] && [ "$target" -nt "$source_file" ]; then
  exit 0
fi

mkdir -p "$(dirname "$target")"
temporary="$target.tmp.$$"
trap 'rm -f "$temporary"' EXIT INT TERM

xcrun swiftc -O "$source_file" -o "$temporary" \
  -framework AppKit -framework ApplicationServices
codesign --force --sign - --identifier com.sem.omniwm-set-frame \
  "$temporary" >/dev/null
mv "$temporary" "$target"
trap - EXIT INT TERM
