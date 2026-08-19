# Minimal Family Travel Laptop

## Install

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AyeCaptn/dotfiles/minimal/installer.sh)"
```

## Update

```sh
update
```

Run `:Lazy sync` separately when you want to update Neovim plugins.

## mise

Language runtimes are installed per project instead of globally:

```sh
cd ~/Projects/my-project
mise use node@lts
mise use python@3.13
```

This creates or updates the project's `mise.toml`. Run `mise install` to install
its declared tools, or use a tool once without adding it to the project:

```sh
mise x python@3.13 -- python script.py
```
