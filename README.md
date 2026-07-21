# Dotfiles

Personal macOS dotfiles for a keyboard-driven desktop built around Ghostty,
tmux, yabai/skhd, SketchyBar, zsh, Starship, and Neovim.

## Install

Bootstrap the system by running the following command:

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AyeCaptn/dotfiles/master/installer.sh)"
```

## Update

Run the following command do update the dotfiles, brew, global npm dependencies and global python packages

```
update
```

## Desktop

The desktop setup is configured through yabai, skhd, and SketchyBar config files
under `tilde/.config`.

Window/app navigation is handled by skhd:

| Key | Action |
| --- | --- |
| `cmd + shift + return` | Focus Ghostty with tmux session `main` |
| `cmd + shift + b/m/w/s/o` | Open Zen, Mail, WhatsApp, Spotify, Obsidian |
| `alt + h/j/k/l` | Focus yabai windows |
| `alt + shift + h/j/k/l` | Swap yabai windows |
| `alt + 1-9` | Focus spaces |
| `alt + shift + 1-9` | Move window to space and follow |
| `alt + shift + ;` | Enter skhd service mode |

## SketchyBar

SketchyBar is configured with SbarLua under `~/.config/sketchybar`.

SbarLua is not installed by Homebrew. Install or update it with:

```sh
git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua
make -C /tmp/SbarLua -f makefile install
rm -rf /tmp/SbarLua
```

The bar shows spaces, focused app, system widgets, connectivity indicators, and
calendar. See `tilde/.config/sketchybar` for the current modules.

## Shell

Zsh plugins are managed by Sheldon. The prompt is Starship. Oh My Zsh is not
used.

See `tilde/.zshrc`, `tilde/.config/sheldon/plugins.toml`, and the files under
`lib/` for the current shell setup.

## Ghostty And Tmux

Ghostty opens zsh, and `.zshrc` handles tmux session attachment for interactive
top-level shells. See `tilde/.config/ghostty/config` and `tilde/.zshrc`.

## Manual

**Set up the trackpad**

**Configure git**

```
git config --global user.email "email@yoursite.com"
git config --global user.name "Name Lastname"
```

**Sync VS code**

**Sync Intellij IDE's**

**Grant permissions**

- Grant Accessibility permissions to skhd, yabai, and borders if macOS prompts.
- Start/restart services after changing configs: `yabai --restart-service`, `skhd --restart-service`, `sketchybar --reload`.

**Finder**

- Add shortcut for the Projects folder to the finder window

**Backups**

- Restore the backups
- Enable the backup schedule
