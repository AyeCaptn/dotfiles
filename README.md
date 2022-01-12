# Dotfiles

Attempt at managing my dotfiles and bootstrapping a fresh system.

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

## Manual

**Set up the trackpad**

**Configure git**

```
git config --global user.email "email@yoursite.com"
git config --global user.name "Name Lastname"
```

**Sync VS code**

**Sync Intellij IDE's**

**Set up iTerm2**

- Set theme in preferences -> profile -> colors
- Set font to Fira code retina in preferences -> profile -> text
- Set theme to minimal in appearance -> general -> theme
- Set settings in advanced:
    - Tabs prominent outline -> 0.1
    - Prominence of selected tabs underline indicator -> 0
- Enable blinking cursor
- Set window size to 125x25
- Enable unlimited scrollback

**Finder**

- Add shortcut for the Projects folder to the finder window

**Backups**

- Restore the backups
- Enable the backup schedule


## Resources

[Denys Dovhan’s dotfiles](https://github.com/denysdovhan/dotfiles)