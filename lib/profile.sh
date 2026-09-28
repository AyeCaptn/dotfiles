#!/bin/sh

# Machine profile helpers shared by the installer and management commands.
# DOTFILES_PROFILE can temporarily override the machine-local selection.

dotfiles_profile_file() {
  printf '%s/dotfiles/profile\n' "${XDG_CONFIG_HOME:-$HOME/.config}"
}

dotfiles_profile_valid() {
  case "$1" in
    personal | work) return 0 ;;
    *) return 1 ;;
  esac
}

dotfiles_profile() {
  local profile_file profile
  profile_file="$(dotfiles_profile_file)"
  profile="${DOTFILES_PROFILE:-}"

  if [ -z "$profile" ] && [ -f "$profile_file" ]; then
    IFS= read -r profile < "$profile_file"
  fi
  [ -n "$profile" ] || profile=personal

  if ! dotfiles_profile_valid "$profile"; then
    printf 'Invalid dotfiles profile: %s (expected personal or work)\n' "$profile" >&2
    return 64
  fi
  printf '%s\n' "$profile"
}

dotfiles_profile_set() {
  local profile_file
  dotfiles_profile_valid "$1" || {
    printf 'Invalid dotfiles profile: %s (expected personal or work)\n' "$1" >&2
    return 64
  }
  profile_file="$(dotfiles_profile_file)"
  mkdir -p "$(dirname "$profile_file")"
  printf '%s\n' "$1" > "$profile_file"
}

dotfiles_brewfiles() {
  local root profile
  root="${1:-${DOTFILES:-$HOME/.dotfiles}}"
  profile="${2:-$(dotfiles_profile)}" || return
  printf '%s\n' "$root/Brewfile" "$root/Brewfile.$profile"
}
