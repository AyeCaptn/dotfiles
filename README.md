# Dotfiles

Personal macOS dotfiles for a keyboard-driven desktop built around Ghostty,
tmux, yabai, skhd, JankyBorders, SketchyBar, Raycast, zsh, Starship, and Neovim.

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

The desktop setup is configured through yabai, skhd, and SketchyBar under
`tilde/.config`.

Window/app navigation is handled by skhd and yabai:

| Key | Action |
| --- | --- |
| `cmd + shift + return` | Focus Ghostty with tmux session `main` |
| `cmd + shift + b/m/w/s/o/k` | Focus browser, mail, chat, Spotify, Obsidian, Calendar |
| `cmd + shift + /` | Show the sticky Finder window on the current Desktop |
| `alt + h/j/k/l` | Focus tiled windows |
| `alt + shift + h/j/k/l` | Swap tiled windows |
| `alt + s` | Toggle the focused window's split direction |
| `alt + 1-9` | Focus native macOS Desktops |
| `alt + shift + 1-9` | Move window to a native Desktop and follow |
| `alt + d` | Move the focused window to its app's home Desktop |
| `alt + q` | Close the focused window, or hide Finder while preserving its tabs |
| `alt + f` | Toggle layout fullscreen |
| `alt + shift + f` | Toggle a centered 50% floating window |
| `alt + c` | Toggle a centered 60% floating window |
| `alt + e/r/y` | Balance, rotate, or mirror the current layout |
| `alt + shift + ;` | Enter the skhd service layer |

The nine native Mission Control Desktops are semantic: `terminal`, `web`,
`comms`, `notes`, `media`, `calendar`, `development`, `creative`, and `office`.
The first standard window of an assigned app opens on its home Desktop;
additional windows remain where they are opened. Utilities such as Finder,
Preview, 1Password, and System Settings stay on the current Desktop.

Create exactly nine Desktops in Mission Control and disable **Automatically
rearrange Spaces based on most recent use** so their numeric meaning remains
stable. Keep **Show Items on Desktop** enabled and set **Click wallpaper to
reveal Desktop** to **Only in Stage Manager**, as required by current
`asmvik/yabai` releases. yabai labels those native Desktops and applies a BSP
layout.

On macOS 27, `build_space_switcher.sh` compiles a small local helper that uses
serialized high-velocity Dock gestures for animationless switching. Grant
`~/.local/bin/yabai-space-switch` **Device Control and Data Access** permission
when prompted. No third-party space-switching application is installed.

The app launch shortcuts find existing windows even when they are on another
Desktop. For a first launch they switch to the app's home Desktop before opening
it; a guarded event hook provides the same routing for apps opened elsewhere.

JankyBorders marks the focused window. yabai frame animations stay disabled
because this setup keeps full SIP enabled; current yabai and JankyBorders
releases support synchronized borders if scripting additions are enabled later.

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

The bar shows native Desktops, focused app, system widgets, connectivity
indicators, and the next calendar event. See `tilde/.config/sketchybar` for the
current modules.

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

- Grant Accessibility permission to yabai, skhd, and borders.
- Run `reload` after changing tmux, yabai, skhd, borders, or SketchyBar configuration.

**Finder**

- Add shortcut for the Projects folder to the finder window

**Backups**

- Restore the backups
- Enable the backup schedule
