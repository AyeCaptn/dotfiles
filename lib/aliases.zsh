#
# Aliases
#

# Enable aliases to be sudo’ed
#   http://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias sudo='sudo '

_exists() {
  command -v $1 >/dev/null 2>&1
}

# Avoid stupidity with trash-cli:
# 	https://github.com/sindresorhus/trash-cli
# or use default rm -i
if _exists trash; then
  alias rm='trash'
fi

# Folders Shortcuts
[ -d ~/Downloads ] && alias dl='cd ~/Downloads'
[ -d ~/Desktop ] && alias dt='cd ~/Desktop'
[ -d ~/Projects ] && alias pj='cd ~/Projects'
[ -d ~/Projects/Forks ] && alias pjf='cd ~/Projects/Forks'
[ -d ~/Projects/Job ] && alias pjj='cd ~/Projects/Job'
[ -d ~/Projects/Playground ] && alias pjp='cd ~/Projects/Playground'
[ -d ~/Projects/Repos ] && alias pjr='cd ~/Projects/Repos'

# Open aliases
alias o='open'
alias oo='open .'

# Get updates, and update npm and its installed packages
alias update="source $DOTFILES/scripts/update.zsh"

# Reload desktop tools after updating their configuration.
reload-desktop() {
  _exists tmux && tmux source-file "$HOME/.tmux.conf"
  _exists sketchybar && sketchybar --reload
  _exists borders && brew services restart felixkratz/formulae/borders
  _exists skhd && skhd --restart-service
  _exists yabai && yabai --restart-service
}

alias reload='reload-desktop'

# Quick jump to dotfiles
alias dotfiles="cd $DOTFILES"

# My IP
alias myip='ifconfig | sed -En "s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p"'

# Password generator
# Gemnerate random password, copies it into clipboard and outputs it to terminal
if _exists pbcopy; then
  alias password='openssl rand -base64 ${1:-9} | pbcopy ; echo "$(pbpaste)"'
elif _exists xcopy; then
  alias password='openssl rand -base64 ${1:-9} | xcopy ; echo "$(xpaste)"'
else
  alias password='openssl rand -base64 ${1:-9}; echo "$(xpaste)"'
fi

# Show $PATH in readable view
alias path='echo -e ${PATH//:/\\n}'

# Download web page with all assets
alias getpage='wget --no-clobber --page-requisites --html-extension --convert-links --no-host-directories'

# Download file with original filename
alias get="curl -O -L"

# Use tldr as help util
if _exists tldr; then
  alias help="tldr"
fi

alias git-root='cd $(git rev-parse --show-toplevel)'

# Docker
alias d='docker'

dstop() {
  local containers
  containers="$(docker ps -q)"
  [[ -n "$containers" ]] && docker stop ${(f)containers}
}

dstart() {
  local containers
  containers="$(docker ps -aq --filter status=exited)"
  [[ -n "$containers" ]] && docker start ${(f)containers}
}

drestart() {
  local containers
  containers="$(docker ps -q)"
  [[ -n "$containers" ]] && docker restart ${(f)containers}
}

# Shortcuts
alias lg=lazygit

# Modern CLI defaults. Guarded so a partial bootstrap still works.
if _exists eza; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza --icons --group-directories-first -la'
  alias lt='eza --icons --tree --level=2'
fi

if _exists bat; then
  alias cat='bat --style=plain'
fi

if _exists yazi; then
  y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
fi

# Backup all files
alias backup="resticprofile -c ~/.resticprofiles.conf --name full-backup backup"

# Disable press and hold in VSCode
alias vscode-press-and-hold-off="defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false"
alias vscode-press-and-hold-on="defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool true"

# NeoVim
alias vi=nvim

# AWSume
alias awsume=". awsume"

alias kaws="tv aws-profiles"
alias ktx="tv k8s-contexts"
