#!/usr/bin/env zsh

# Blessed update path for dotfiles, Homebrew, development runtimes, and
# ecosystem-managed CLI applications.

set -eu
setopt pipefail

export DOTFILES=${1:-"$HOME/.dotfiles"}
source "$DOTFILES/lib/profile.sh"
export DOTFILES_PROFILE="$(dotfiles_profile)" || exit
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
lock_dir="${TMPDIR:-/tmp}/dotfiles-update-${UID}.lock"
log_file="$state_dir/update.log"
desktop_services_suspended=0
desktop_wm_before_update="none"
skhd_before_update=0

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
  restore_desktop_services || true
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

suspend_desktop_services() {
  [[ -x "$DOTFILES/bin/desktop-wm" ]] || return

  if pgrep -x OmniWM >/dev/null; then
    desktop_wm_before_update="omniwm"
  elif pgrep -x yabai >/dev/null; then
    desktop_wm_before_update="yabai"
  fi
  pgrep -x skhd >/dev/null && skhd_before_update=1

  info "Temporarily stopping desktop input hooks"
  desktop_services_suspended=1
  "$DOTFILES/bin/desktop-wm" stop
}

restore_desktop_services() {
  (( desktop_services_suspended )) || return 0

  case "$desktop_wm_before_update" in
    omniwm|yabai)
      info "Restoring $desktop_wm_before_update desktop services"
      "$DOTFILES/bin/desktop-wm" "$desktop_wm_before_update"
      ;;
    *)
      if (( skhd_before_update )) && _exists skhd; then
        info "Restoring skhd"
        skhd --start-service
      fi
      ;;
  esac

  desktop_services_suspended=0
}

update_homebrew() {
  _exists brew || return
  section "Updating Homebrew packages and applications"

  brew update
  # skhd and OmniWM own global event taps. Replacing either executable while
  # its old process is alive can wedge local input or invalidate macOS TCC
  # state. Stop both before Homebrew mutates them and restore the previous mode
  # afterward. The EXIT trap also restores them when an update fails.
  suspend_desktop_services
  local brewfile
  for brewfile in "${(@f)$(dotfiles_brewfiles "$DOTFILES" "$DOTFILES_PROFILE")}"; do
    brew bundle --file "$brewfile"
  done
  # Also update intentionally installed packages that have not yet been added
  # to the Brewfile. `dot doctor` reports that drift for later review.
  brew upgrade
  brew cleanup
  restore_desktop_services
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

  local resticprofile_bin="/opt/homebrew/bin/resticprofile"
  if _exists brew; then
    resticprofile_bin="$(brew --prefix)/bin/resticprofile"
  fi

  if [[ "$DOTFILES_PROFILE" == "personal" && -x "$resticprofile_bin" && -f "$HOME/.resticprofiles.conf" ]]; then
    env PATH="$(dirname "$resticprofile_bin"):/usr/bin:/bin:/usr/sbin:/sbin" \
      "$resticprofile_bin" --config "$HOME/.resticprofiles.conf" schedule --all --start
  fi

  local opencode_tailnet_agent="$DOTFILES/tilde/Library/LaunchAgents/com.sem.opencode-tailnet.plist"
  if [[ "$DOTFILES_PROFILE" == "personal" ]] && _exists opencode && [[ -f "$opencode_tailnet_agent" ]]; then
    opencode service set hostname 127.0.0.1
    opencode service set port 49374
    if _exists tailscale; then
      tailscale serve --bg --tcp=4096 tcp://127.0.0.1:49374
    fi
    mkdir -p "$HOME/Library/LaunchAgents"
    local opencode_tailnet_agent_target="$HOME/Library/LaunchAgents/com.sem.opencode-tailnet.plist"
    [[ "$opencode_tailnet_agent" -ef "$opencode_tailnet_agent_target" ]] || \
      cp "$opencode_tailnet_agent" "$opencode_tailnet_agent_target"
    launchctl bootout "gui/$(id -u)/com.sem.opencode-tailnet" >/dev/null 2>&1 || true
    launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.sem.opencode-tailnet.plist"
    launchctl enable "gui/$(id -u)/com.sem.opencode-tailnet"
  elif [[ "$DOTFILES_PROFILE" == "work" ]]; then
    launchctl bootout "gui/$(id -u)/com.sem.opencode-tailnet" >/dev/null 2>&1 || true
  fi

  if [[ -x "$DOTFILES/bin/desktop-wm" ]]; then
    "$DOTFILES/bin/desktop-wm" reload
  fi
}

main() {
  info "Starting managed system update"
  info "Profile: $DOTFILES_PROFILE"
  info "Log: $log_file"

  update_dotfiles
  update_homebrew
  update_mise
  update_rust
  update_pnpm
  update_uv
  update_shell_plugins
  refresh_services

  # Defer the interactive shell reminder for another week after a successful
  # complete update.
  touch "$state_dir/update-reminder"

  print
  success "Managed system update complete."
}

main
