alias dotfiles='cd "$DOTFILES"'
alias update='"$DOTFILES/scripts/update.zsh"'
alias vi='nvim'
alias vim='nvim'
alias t='tmux'
alias mx='mise x --'
alias o='open'
alias oo='open .'

[[ -d "$HOME/Projects" ]] && alias pj='cd "$HOME/Projects"'
[[ -d "$HOME/Projects/Forks" ]] && alias pjf='cd "$HOME/Projects/Forks"'
[[ -d "$HOME/Projects/Job" ]] && alias pjj='cd "$HOME/Projects/Job"'
[[ -d "$HOME/Projects/Playground" ]] && alias pjp='cd "$HOME/Projects/Playground"'
[[ -d "$HOME/Projects/Repos" ]] && alias pjr='cd "$HOME/Projects/Repos"'

alias g='git'
alias gs='git status --short --branch'
alias gcl='git clone'

pclone() {
  if (( $# == 0 )); then
    print -u2 "usage: pclone [git clone options] <repository>"
    return 2
  fi

  git -C "$HOME/Projects/Repos" clone "$@"
}

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza --group-directories-first --long --all --git'
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --style=plain --paging=never'
fi
