# macOS dotfiles

Configuration for zsh, Ghostty, tmux, Neovim, OpenCode, and a keyboard-driven
desktop using OmniWM, skhd, and SketchyBar.

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
desktop-wm stop # Release input hooks for recovery from a remote shell
```

## NAS uploads

The [manual Docker settings](https://github.com/AyeCaptn/nas-images/tree/main/images/nas-upload)
are maintained in the private `nas-images` repository.

```sh
nas-upload "/path/to/movie.mkv"             # Upload to downloads/Uploads
nas-upload --dry-run "/path/to/movie.mkv"   # Preview only
nas-upload "/path/to/movie.mkv" incoming    # Existing subfolder of Uploads
```

Uses rsync over SSH directly to `192.168.1.145:2222`, with idle-sleep prevention.
Rerun the same command to reuse interrupted transfers. Local files are kept;
matching destination files may be replaced. For transfers that should survive
closing the terminal, run inside `tmux new -s nas-upload`.

Requires the dedicated local key `~/.ssh/ugreen_nas_ed25519`, its public key
authorized for container user `upload`, and a trusted container host key in
`~/.ssh/known_hosts`. Access is restricted to Uploads. Host SSH, SMB, SFTP, and
the rsync daemon are not needed. See `nas-upload --help` for overrides.

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
