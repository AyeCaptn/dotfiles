#!/usr/bin/env zsh

# Blessed update path for dotfiles, Homebrew, development runtimes, and
# ecosystem-managed CLI applications.

set -eu
setopt pipefail

export DOTFILES=${1:-"$HOME/.dotfiles"}
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
lock_dir="${TMPDIR:-/tmp}/dotfiles-update-${UID}.lock"
log_file="$state_dir/update.log"

e='\033'
RESET="${e}[0m"
CYAN="${e}[0;96m"
RED="${e}[0;91m"
GREEN="${e}[0;92m"

info() {
  print -P "%F{cyan}$*%f"
}

success() {
  print -P "%F{green}$*%f"
}

error() {
  print -P "%F{red}$*%f" >&2
}

section() {
  print
  info "$1"
}

_exists() {
  command -v "$1" >/dev/null 2>&1
}

cleanup() {
  local status=$?
  trap - EXIT
  rm -rf -- "$lock_dir"
  if (( status != 0 )); then
    error "Update failed. Review $log_file"
  fi
  exit $status
}

if ! mkdir "$lock_dir" 2>/dev/null; then
  owner="$(cat "$lock_dir/pid" 2>/dev/null || print unknown)"
  if [[ $owner == <-> ]] && kill -0 "$owner" 2>/dev/null; then
    error "Another update is already running (PID $owner)."
    exit 1
  fi
  info "Removing a stale update lock from PID $owner."
  rm -rf -- "$lock_dir"
  mkdir "$lock_dir"
fi
print $$ > "$lock_dir/pid"
trap cleanup EXIT
trap 'exit 130' HUP INT TERM

mkdir -p "$state_dir"
touch "$log_file"
exec > >(tee -a "$log_file") 2>&1

update_dotfiles() {
  section "Updating dotfiles"

  cd "$DOTFILES"
  if ! git diff --quiet || ! git diff --cached --quiet \
    || [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
    info "Dotfiles contain local changes; skipping git pull."
  elif git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1; then
    git pull --ff-only
  else
    info "The current dotfiles branch has no upstream; skipping git pull."
  fi

  "$DOTFILES/sync.py" --yes
}

update_homebrew() {
  _exists brew || return
  section "Updating Homebrew packages and applications"

  brew update
  brew bundle --file "$DOTFILES/Brewfile"
  # Also update intentionally installed packages that have not yet been added
  # to the Brewfile. `dot doctor` reports that drift for later review.
  brew upgrade
  brew cleanup
}

update_mise() {
  _exists mise || return
  section "Updating mise development environments"

  # An explicit system update asks for current releases immediately. Keep old
  # installs until a later prune so live terminals and services remain valid.
  MISE_MINIMUM_RELEASE_AGE=0 mise upgrade --no-prune
}

update_rust() {
  _exists rustup || return
  section "Updating Rust"
  rustup update
}

update_pnpm() {
  _exists pnpm || return
  section "Updating pnpm CLI applications"
  pnpm update --global --latest
}

update_uv() {
  _exists uv || return
  section "Updating uv and Python CLI applications"
  uv self update
  uv tool upgrade --all
}

update_shell_plugins() {
  _exists sheldon || return
  section "Updating Zsh plugins"
  sheldon lock --update
}

refresh_services() {
  section "Refreshing managed services"

  if _exists resticprofile && [[ -f "$HOME/.resticprofiles.conf" ]]; then
    resticprofile --config "$HOME/.resticprofiles.conf" schedule --all --start
  fi

  if _exists opencode && opencode service status >/dev/null 2>&1; then
    opencode service restart
  fi

  if [[ -x "$DOTFILES/bin/desktop-wm" ]]; then
    "$DOTFILES/bin/desktop-wm" reload
  fi
}

main() {
  info "Starting managed system update"
  info "Log: $log_file"

  update_dotfiles
  update_homebrew
  update_mise
  update_rust
  update_pnpm
  update_uv
  update_shell_plugins
  refresh_services

  print
  success "Managed system update complete."
}

main
