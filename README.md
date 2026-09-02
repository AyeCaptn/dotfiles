# Dotfiles

Personal macOS dotfiles for a keyboard-driven desktop built around Ghostty,
tmux, yabai/skhd, SketchyBar, Raycast, zsh, Starship, and Neovim.

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
| `cmd + shift + b/m/w/s/o/k` | Focus browser, mail, chat, Spotify, Obsidian, Calendar |
| `alt + h/j/k/l` | Focus yabai windows |
| `alt + shift + h/j/k/l` | Swap yabai windows |
| `alt + s` | Toggle the focused window's split direction |
| `alt + 1-9` | Focus spaces |
| `alt + shift + 1-9` | Move window to space and follow |
| `alt + d` | Move the focused window to its app's home space |
| `alt + shift + d` | Organize controllable app windows into their home spaces |
| `alt + shift + ;` | Enter skhd service mode |

The nine fixed spaces are `terminal`, `web`, `comms`, `notes`, `media`,
`calendar`, `development`, `creative`, and `office`. The first window of an
assigned app opens on its home space; additional windows remain where they are
opened. Utilities such as Finder, Preview, 1Password, and System Settings stay
on the current space.

Create exactly nine Spaces in Mission Control. Keep their numeric meaning stable
by disabling **Automatically rearrange Spaces based on most recent use**, or run:

```sh
defaults write com.apple.dock mru-spaces -bool false
killall Dock
```

The mail launcher prefers Microsoft Outlook and falls back to Mail. The chat
launcher similarly prefers Microsoft Teams and falls back to WhatsApp.

## SketchyBar

SketchyBar is configured with SbarLua under `~/.config/sketchybar`.

SbarLua is not installed by Homebrew. Install or update it with:

```sh
git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua
make -C /tmp/SbarLua -f makefile install
rm -rf /tmp/SbarLua
```

The bar shows spaces, focused app, system widgets, connectivity indicators, and
the next calendar event. See `tilde/.config/sketchybar` for the current modules.

## Raycast

Raycast replaces Spotlight on `cmd + space` and is installed through the
`Brewfile`. Its settings and backups are managed outside this repository.

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
- Run `reload` after changing tmux, SketchyBar, borders, skhd, or yabai configuration.

**Finder**

- Add shortcut for the Projects folder to the finder window

**Backups**

- Restore the backups
- Enable the backup schedule
