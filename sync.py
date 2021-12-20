#!/usr/bin/env python3

"""
Dotfiles syncronization.
Makes symlinks for all files: ./tilde/.zshrc will by available as ~/.zshrc.
Based on: https://github.com/denysdovhan/dotfiles/blob/master/sync.py
"""

import os
import sys
import shutil

# Get first, second an third arguments
arg1 = sys.argv[1] if 1 < len(sys.argv) else None  # Source
arg2 = sys.argv[2] if 2 < len(sys.argv) else None  # Dest
arg3 = sys.argv[3] if 3 < len(sys.argv) else None  # Backup

DOTFILES_DIR = os.path.dirname(os.path.abspath(__file__))
SOURCE_DIR = os.path.join(DOTFILES_DIR, arg1 or "tilde")
DEST_DIR = arg2 or os.path.expanduser("~")
BACKUP_DIR = os.path.join(DOTFILES_DIR, arg3 or "backup")
EXCLUDE = []


def forse_remove(path: str):
    """Force remove the given path"""
    if os.path.isdir(path) and not os.path.islink(path):
        shutil.rmtree(path, False)
    else:
        os.unlink(path)


def is_link_to(link: str, dest: str) -> bool:
    """Return True if the given link links to the destination"""
    return os.path.islink(link) and os.readlink(link).rstrip("/") == dest.rstrip("/")


def copy(path: str, dest: str):
    """Copy folders and/or files"""
    if os.path.isdir(path):
        shutil.copytree(path, dest)
    else:
        shutil.copy(path, dest)


def symlink_all():
    """Symlink all files"""
    os.chdir(SOURCE_DIR)
    for filename in [file for file in os.listdir(".") if file not in EXCLUDE]:
        dotfile = os.path.join(DEST_DIR, filename)
        source = os.path.relpath(filename, os.path.dirname(dotfile))

        # check that we aren't overwriting anything
        if os.path.exists(dotfile):
            if is_link_to(dotfile, source):
                continue

            res = input(f"Overwrite file `{dotfile}'? [y/N] ")
            if not res.lower().startswith("y"):
                print(f"Skipping `{dotfile}'...")
                continue
            else:
                # Made backup copy if we're overwriting this file
                res = input(f"Make a backup of `{dotfile}'? [y/N] ")
                if res.lower().startswith("y"):
                    if not os.path.exists(BACKUP_DIR):
                        os.mkdir(BACKUP_DIR)
                    backup = os.path.join(BACKUP_DIR, os.path.basename(dotfile))
                    copy(dotfile, backup)
                    print(f"Made a backup `{dotfile}'")

            forse_remove(dotfile)

        os.symlink(source, dotfile)
        print(f"{dotfile} => {source}")


if __name__ == "__main__":
    symlink_all()
