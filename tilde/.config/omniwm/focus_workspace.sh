#!/usr/bin/env sh

set -eu

workspace="${1:?workspace number or name required}"
omniwmctl workspace focus-name "$workspace" >/dev/null
