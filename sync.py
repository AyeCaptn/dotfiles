#!/usr/bin/env python3

"""Link the minimal profile into the home directory without replacing ~/.config."""

from pathlib import Path
import os
import shutil
import sys


DOTFILES_DIR = Path(__file__).resolve().parent
SOURCE_DIR = DOTFILES_DIR / (sys.argv[1] if len(sys.argv) > 1 else "tilde")
DEST_DIR = Path(sys.argv[2]).expanduser() if len(sys.argv) > 2 else Path.home()
BACKUP_DIR = DOTFILES_DIR / (sys.argv[3] if len(sys.argv) > 3 else "backup")

HOME_ITEMS = (".gitignore", ".tmux.conf", ".zshrc")
CONFIG_ITEMS = ("ghostty", "mise", "nvim", "opencode", "starship.toml")


def exists(path: Path) -> bool:
    return os.path.lexists(path)


def points_to(link: Path, source: Path) -> bool:
    if not link.is_symlink():
        return False

    try:
        return os.path.samefile(link, source)
    except FileNotFoundError:
        return os.path.realpath(link) == os.path.realpath(source)


def remove(path: Path) -> None:
    if path.is_dir() and not path.is_symlink():
        shutil.rmtree(path)
    else:
        path.unlink()


def back_up(path: Path, relative_path: Path) -> None:
    backup = BACKUP_DIR / relative_path
    backup.parent.mkdir(parents=True, exist_ok=True)
    if exists(backup):
        remove(backup)

    if path.is_dir() and not path.is_symlink():
        shutil.copytree(path, backup, symlinks=True)
    else:
        shutil.copy2(path, backup, follow_symlinks=False)


def link(source: Path, destination: Path, relative_path: Path) -> None:
    if points_to(destination, source):
        return

    if exists(destination):
        answer = input(f"Overwrite '{destination}'? [y/N] ")
        if not answer.lower().startswith("y"):
            print(f"Skipping '{destination}'")
            return

        answer = input(f"Back up '{destination}' first? [y/N] ")
        if answer.lower().startswith("y"):
            back_up(destination, relative_path)
        remove(destination)

    destination.parent.mkdir(parents=True, exist_ok=True)
    target = os.path.relpath(source.resolve(), destination.parent.resolve())
    destination.symlink_to(target, target_is_directory=source.is_dir())
    print(f"{destination} => {target}")


def prepare_config_directory(source: Path, destination: Path) -> None:
    # Migrate the old whole-directory link without touching its target.
    if points_to(destination, source):
        destination.unlink()
    elif destination.is_symlink():
        raise SystemExit(
            f"Refusing to modify '{destination}': it links to another dotfiles tree"
        )

    if exists(destination) and not destination.is_dir():
        answer = input(f"Replace '{destination}' with a directory? [y/N] ")
        if not answer.lower().startswith("y"):
            raise SystemExit("Cannot link application configuration")
        remove(destination)

    destination.mkdir(parents=True, exist_ok=True)


def sync() -> None:
    config_source = SOURCE_DIR / ".config"
    config_destination = DEST_DIR / ".config"
    prepare_config_directory(config_source, config_destination)

    for name in HOME_ITEMS:
        link(SOURCE_DIR / name, DEST_DIR / name, Path(name))

    for name in CONFIG_ITEMS:
        link(
            config_source / name,
            config_destination / name,
            Path(".config") / name,
        )


if __name__ == "__main__":
    sync()
