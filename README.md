# macOS dotfiles

Configuration for zsh, Ghostty, tmux, Neovim, OpenCode, and a keyboard-driven
desktop using OmniWM, skhd, and SketchyBar. Yabai remains available as a fallback.

## Setup

Requires macOS and Xcode Command Line Tools.

```sh
git clone https://github.com/AyeCaptn/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bin/dot profile personal # or work
./bin/dot bootstrap
```

Bootstrap installs packages, links configuration, and sets up login services.
The personal profile also restores backups when 1Password is available.
Grant Accessibility and Input Monitoring access to desktop tools when prompted.

## Maintenance

```sh
dot update          # Update packages and restore managed services
dot doctor          # Check packages, runtimes, links, and credential patterns
./sync.py --dry-run # Preview configuration links
dot sync            # Apply links; back up replaced files
dot profile         # Show the active profile
```

Use `dot update` for package maintenance. It stops desktop input hooks before
replacing their executables and restores the active window manager afterward.

```sh
desktop-wm status
desktop-wm omniwm
desktop-wm yabai
desktop-wm stop # Release input hooks for recovery from a remote shell
```

## Repository layout

- `tilde/`: shared home-directory configuration; only tracked files are linked.
- `profiles/<profile>/tilde/`: profile-specific overrides.
- `Brewfile*`, `python-packages*.txt`, `pnpm-packages.txt`: managed packages.
- `bin/`, `scripts/`, `lib/`: commands, bootstrap, update, and shell helpers.
- `skills/`: reusable project skills.

OpenCode loads shared `opencode.json` and the selected profile's `opencode.jsonc`.
Grounded Docs maintains its documentation index outside the repository.

## Local configuration

Keep credentials and machine-specific settings outside Git. Zsh loads
`~/.secrets` and `~/.zshlocal`; use the latter for local certificate settings.
LazyGit merges `~/.config/lazygit/config.local.yml` when present.
The selected profile, generated state, and replacement backups are local.
