#!/usr/bin/env sh

set -eu

workspace="${1:?workspace number required}"
omniwmctl command move-to-workspace "$workspace" >/dev/null
omniwmctl command switch-workspace "$workspace" >/dev/null
