#!/usr/bin/env python3

"""Safely link tracked dotfiles into a destination directory.

Directories are merged and only individual tracked files are linked. Existing
directories are never recursively removed. Replaced files and symlinks are
backed up under ``backup/<timestamp>/`` with their relative paths preserved.
"""

import argparse
import os
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Iterable, List


DOTFILES_DIR = Path(__file__).resolve().parent


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "source",
        nargs="?",
        default="tilde",
        help="source directory, relative to the dotfiles repository (default: tilde)",
    )
    parser.add_argument(
        "destination",
        nargs="?",
        default=str(Path.home()),
        help="destination directory (default: home directory)",
    )
    parser.add_argument(
        "backup",
        nargs="?",
        default="backup",
        help="backup directory, relative to the repository (default: backup)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="show planned changes without modifying anything",
    )
    parser.add_argument(
        "--yes",
        action="store_true",
        help="replace conflicting files without prompting (backups are still made)",
    )
    return parser.parse_args()


def tracked_files(source_dir: Path) -> List[Path]:
    """Return Git-tracked files below source_dir, relative to source_dir."""
    try:
        source_relative = source_dir.relative_to(DOTFILES_DIR)
    except ValueError as error:
        raise ValueError("source must be inside the dotfiles repository") from error

    result = subprocess.run(
        [
            "git",
            "-C",
            str(DOTFILES_DIR),
            "ls-files",
            "-z",
            "--",
            str(source_relative),
        ],
        check=True,
        stdout=subprocess.PIPE,
    )
    prefix = str(source_relative) + os.sep
    files = []
    for raw_path in result.stdout.split(b"\0"):
        if not raw_path:
            continue
        repository_path = os.fsdecode(raw_path)
        if repository_path == str(source_relative):
            files.append(Path(source_dir.name))
        elif repository_path.startswith(prefix):
            files.append(Path(repository_path[len(prefix) :]))
    return sorted(files)


def already_managed(destination: Path, source: Path) -> bool:
    """Return whether destination already resolves to the tracked source."""
    if not os.path.lexists(str(destination)):
        return False
    try:
        return destination.resolve(strict=False) == source.resolve(strict=False)
    except OSError:
        return False


def prompt_to_replace(destination: Path) -> bool:
    response = input(f"Replace `{destination}`? [y/N] ")
    return response.lower().startswith("y")


def backup_path(destination: Path, destination_root: Path, backup_root: Path) -> Path:
    relative = destination.relative_to(destination_root)
    return backup_root / relative


def make_backup(source: Path, backup: Path, dry_run: bool) -> None:
    print(f"backup  {source} -> {backup}")
    if dry_run:
        return
    backup.parent.mkdir(parents=True, exist_ok=True)
    if source.is_symlink():
        backup.symlink_to(os.readlink(str(source)))
    else:
        shutil.copy2(str(source), str(backup))


def ensure_parent(path: Path, dry_run: bool) -> bool:
    parent = path.parent
    if parent.exists() and not parent.is_dir():
        print(f"refuse  parent is not a directory: {parent}", file=sys.stderr)
        return False
    if not parent.exists():
        print(f"mkdir   {parent}")
        if not dry_run:
            parent.mkdir(parents=True, exist_ok=True)
    return True


def link_files(
    files: Iterable[Path],
    source_root: Path,
    destination_root: Path,
    backup_root: Path,
    dry_run: bool,
    assume_yes: bool,
) -> int:
    failures = 0
    for relative in files:
        source = source_root / relative
        destination = destination_root / relative

        if not source.exists() and not source.is_symlink():
            print(f"skip    tracked source is missing: {source}", file=sys.stderr)
            failures += 1
            continue
        if already_managed(destination, source):
            continue
        if not ensure_parent(destination, dry_run):
            failures += 1
            continue

        if os.path.lexists(str(destination)):
            if destination.is_dir() and not destination.is_symlink():
                print(
                    f"refuse  destination is a directory: {destination}",
                    file=sys.stderr,
                )
                failures += 1
                continue
            if not assume_yes and not dry_run and not prompt_to_replace(destination):
                print(f"skip    {destination}")
                continue
            make_backup(
                destination,
                backup_path(destination, destination_root, backup_root),
                dry_run,
            )
            if not dry_run:
                destination.unlink()

        relative_target = os.path.relpath(str(source), str(destination.parent))
        print(f"link    {destination} -> {relative_target}")
        if not dry_run:
            destination.symlink_to(relative_target)
    return failures


def main() -> int:
    args = parse_args()
    source_root = (DOTFILES_DIR / args.source).resolve()
    destination_root = Path(args.destination).expanduser().resolve()
    backup_base = Path(args.backup).expanduser()
    if not backup_base.is_absolute():
        backup_base = DOTFILES_DIR / backup_base
    backup_root = backup_base / datetime.now().strftime("%Y%m%d-%H%M%S")

    if not source_root.is_dir():
        print(f"source is not a directory: {source_root}", file=sys.stderr)
        return 2
    if not destination_root.is_dir():
        print(f"destination is not a directory: {destination_root}", file=sys.stderr)
        return 2

    try:
        files = tracked_files(source_root)
    except (ValueError, subprocess.CalledProcessError) as error:
        print(f"cannot list tracked files: {error}", file=sys.stderr)
        return 2

    failures = link_files(
        files,
        source_root,
        destination_root,
        backup_root,
        args.dry_run,
        args.yes,
    )
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
