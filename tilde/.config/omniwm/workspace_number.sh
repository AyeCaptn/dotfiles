#!/usr/bin/env sh

# Translate the semantic workspace names shared with the yabai fallback.
case "${1:-}" in
  terminal) printf '1\n' ;;
  web) printf '2\n' ;;
  comms) printf '3\n' ;;
  notes) printf '4\n' ;;
  media) printf '5\n' ;;
  calendar) printf '6\n' ;;
  development) printf '7\n' ;;
  creative) printf '8\n' ;;
  office) printf '9\n' ;;
  *) exit 1 ;;
esac
