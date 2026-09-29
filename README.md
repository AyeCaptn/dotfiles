# Dotfiles

Personal macOS dotfiles for a keyboard-driven desktop built around Ghostty,
tmux, OmniWM, skhd, SketchyBar, Raycast, zsh, Starship, and Neovim. The former
yabai and JankyBorders desktop remains installed and fully configured as a
fallback.

## Install

Bootstrap the system by running the following command:

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AyeCaptn/dotfiles/master/installer.sh)"
```

The default `personal` profile installs the complete setup. On a work Mac, use
the `work` profile instead:

```sh
curl -fsSL https://raw.githubusercontent.com/AyeCaptn/dotfiles/master/installer.sh \
  | bash -s -- --profile work
```

The selected profile is stored locally in `~/.config/dotfiles/profile`; it is
not linked into this repository. View or change it with `dot profile` and
`dot profile personal|work`, then run `dot bootstrap` and start a new shell to
apply it.

Both profiles install the full keyboard-driven desktop and broad developer
toolchain. The work profile keeps Ghostty, Docker Desktop, VS Code, Obsidian,
Helium, Zen, 1Password, Raycast, cloud/Kubernetes tools, JVM/Scala, iOS/macOS
tools, language runtimes, and the common CLI environment. It omits personal
backup, Tailscale, NAS, Affinity, tldraw-vault, media/photo, and personal helper
packages and configuration. Profile changes never uninstall packages.

Homebrew packages shared by both machines live in `Brewfile`; additions live
in `Brewfile.personal` and `Brewfile.work`. Python CLI packages follow the same
pattern.

`sync.py` links only Git-tracked files. It merges directory trees instead of
replacing them, so broad home directories such as `~/Library` are never
deleted. Preview changes with `./sync.py --dry-run`; replaced files are backed
up under `backup/<timestamp>/`.

## Update

Run the blessed update path to update dotfiles, Homebrew packages and apps,
mise development environments, Rust, and ecosystem CLI tools:

```sh
dot update
```

The `update` alias runs the same command. Updates are locked against concurrent
runs and logged to `~/.local/state/dotfiles/update.log`. OpenCode is installed
through Homebrew. On the personal profile, an authenticated login agent also
keeps the web server available on the Tailscale-only
endpoint `http://100.86.28.24:4096`. Remote access uses the username `opencode`;
its stable password is stored in the login Keychain as the Internet Password
**OpenCode via Tailscale** for `sems-macbook-pro.tailbf6441.ts.net:4096`.

An interactive shell shows a `dot update` reminder at most once every seven
days. Completing the update successfully resets the reminder timer.

Check the managed system without changing it:

```sh
dot doctor
```

The doctor checks the active profile's Brewfiles, mise runtimes, dotfile links, generated files,
common credential patterns, and unmanaged Homebrew installations. Unmanaged
packages are reported for review but are never removed automatically.

## Remote workstation power profile

Normal macOS sleep remains enabled. To temporarily keep the Mac awake as a
remote workstation while it is connected to AC power, use the native
`caffeinate`-backed profile:

```sh
remote-workstation on
remote-workstation all-on
remote-workstation status
remote-workstation off
```

The `on` profile persists across logins until it is turned off, allows the
display to sleep, and only prevents system sleep on AC power. The `all-on`
profile also keeps the display on and suppresses the screen saver. Neither mode
overrides the MacBook's lid-close behavior. The SketchyBar coffee cup cycles
through normal (green), `on` (orange), and `all-on` (purple); red means another
process is blocking sleep.

## Desktop

The primary desktop uses OmniWM's Dwindle (BSP) layout, built-in OmniWM hotkeys
and synchronized borders, skhd for scripted overlays and app launchers, and SketchyBar. Its
configuration is under `tilde/.config/omniwm`; the complete yabai setup remains
under `tilde/.config/yabai` and `tilde/.config/skhd/skhdrc.yabai`.

Window/app navigation keeps the established keymap:

| Key | Action |
| --- | --- |
| `cmd + shift + return` | Focus Ghostty with tmux session `main` |
| `cmd + shift + b/m/w/s/o/k` | Focus browser, mail, chat, Spotify, Obsidian, Calendar |
| `cmd + shift + /` | Show the persistent Finder overlay on the current workspace |
| `alt + h/j/k/l` | Focus tiled windows; `h/l` enter an occupied adjacent workspace at the layout edge |
| `alt + shift + h/j/k/l` | Swap tiled windows |
| `alt + s` | Toggle the focused window's split direction |
| `alt + 1-9` | Focus a numbered workspace |
| `alt + shift + 1-9` | Move a window to a workspace and follow |
| `alt + d` | Move the focused window to its app's home workspace |
| `alt + q` | Close the focused window, or hide Finder while preserving its tabs |
| `alt + f` | Toggle border-preserving fullscreen |
| `alt + shift + f` | Toggle a centered 50% floating window |
| `alt + c` | Toggle a centered 60% floating window |
| `alt + e/r/y` | Balance or transform the current BSP layout |
| `alt + shift + ;` | Enter the skhd service layer |

Under OmniWM, `alt + r` swaps the focused Dwindle split and `alt + y` moves the
focused tile to the root. These are the closest available equivalents to
yabai's whole-tree rotate and mirror operations. The exact original operations
remain available in the yabai fallback.

The nine OmniWM workspaces are semantic: `terminal`, `web`, `comms`, `notes`,
`media`, `calendar`, `development`, `creative`, and `office`. The first standard
window of an assigned app opens on its home workspace; additional windows
remain where they are opened. Utilities such as Finder, Preview, 1Password, and
System Settings float on the current workspace. `alt + c` toggles a centered
60% floating overlay, while `cmd + shift + /` summons and sizes the persistent
Finder overlay on the current workspace.

Centered floating windows use OmniWM's native floating mode plus the
`omniwm-set-frame` Accessibility helper. Direct AX sizing keeps OmniWM's native
focus border synchronized; using System Events/AppleScript here would suppress
the floating border until the window returned to tiling.

OmniWM intentionally hides borders for true layout fullscreen. The `alt + f`
binding therefore uses a reversible bordered-fullscreen overlay sized to the
display's configured outer gaps. A second press restores the previous tiled or
floating mode and geometry. Native borderless fullscreen remains available from
OmniWM's command palette.

OmniWM uses its synchronized 4-point Catppuccin Macchiato focus border, 8-point
inner gaps, small enabled animations, and a 0.1-second Quake terminal animation.
SketchyBar continues to show workspace occupancy and app icons, now through
OmniWM IPC. Its built-in workspace bar stays disabled to avoid drawing a second
bar.

OmniWM uses one native macOS Space and requires **Displays have separate
Spaces**. Its virtual workspaces replace the nine native Desktops while it is
active. The original native-Space behavior below applies when using the yabai
fallback.

Switch window managers with:

```sh
desktop-wm omniwm  # primary; stops yabai and JankyBorders
desktop-wm yabai   # fallback; quits OmniWM and restores both services
desktop-wm status
```

The switch also selects the matching skhd profile and reloads SketchyBar. A
user LaunchAgent runs `desktop-wm omniwm` at login. No yabai file is rewritten
or removed.

`dot update` temporarily stops OmniWM and skhd before Homebrew changes their
binaries, then restores the active desktop mode. This avoids leaving stale
global input event taps alive across an application or formula replacement.
If local keyboard or pointer input ever becomes unresponsive, use a remote
shell to release all desktop input hooks without rebooting:

```sh
desktop-wm stop
desktop-wm omniwm
```

If the second command reports that skhd lacks Accessibility access, re-enable
skhd in **System Settings → Privacy & Security → Accessibility**, then run
`desktop-wm reload`.

### yabai fallback

The nine native Mission Control Desktops are semantic in the same order. The
first standard window of an assigned app opens on its home Desktop; additional
windows remain where they are opened.

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

JankyBorders marks the focused window in fallback mode. yabai frame animations
stay disabled because this setup keeps full SIP enabled; current yabai and JankyBorders
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

The bar shows OmniWM workspaces (or native Desktops in fallback mode), focused
app, system widgets, connectivity indicators, and the next calendar event. See
`tilde/.config/sketchybar` for the current modules.

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

- Grant Accessibility and Input Monitoring permission to OmniWM. Screen
  Recording is optional but enables Overview thumbnails and previews.
- Keep Accessibility permission for yabai, skhd, and borders so fallback mode
  remains immediately usable.
- Run `reload` after changing tmux, OmniWM, yabai, skhd, borders, or SketchyBar
  configuration.

**Finder**

- Add shortcut for the Projects folder to the finder window

**Backups**

- Restore the backups
- Enable the backup schedule
