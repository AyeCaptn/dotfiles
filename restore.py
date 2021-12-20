#!/usr/bin/env python3

"""
Restoring files.
Restore files from backup into home.
Based on: https://github.com/denysdovhan/dotfiles/blob/master/restore.py
"""

import os
import shutil

DOTFILES_DIR = os.path.dirname(os.path.abspath(__file__))
BACKUP_DIR = os.path.join(DOTFILES_DIR, "backup")
HOME_DIR = os.path.expanduser("~")


def forse_remove(path: str):
    """Force remove the given path"""
    if os.path.isdir(path) and not os.path.islink(path):
        shutil.rmtree(path, False)
    else:
        os.unlink(path)


def copy(path: str, dest: str):
    """Copy folders and/or files"""
    if os.path.isdir(path):
        shutil.copytree(path, dest)
    else:
        shutil.copy(path, dest)


def restore():
    if os.path.exists(BACKUP_DIR):
        os.chdir(BACKUP_DIR)
        for filename in os.listdir(BACKUP_DIR):
            dest = os.path.join(HOME_DIR, filename)
            if os.path.exists(dest):
                forse_remove(dest)
            copy(filename, dest)
            print(f"'{dest}' has been restored!")
    else:
        print(f"There isn't backup in '{BACKUP_DIR}'!")


if __name__ == "__main__":
    restore()
