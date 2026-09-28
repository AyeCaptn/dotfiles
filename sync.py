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
from typing import Dict, Iterable, List, Tuple


DOTFILES_DIR = Path(__file__).resolve().parent
PROFILES = ("personal", "work")
WORK_EXCLUDES = (
    Path(".resticprofiles.conf"),
    Path("Library/LaunchAgents/com.sem.opencode-tailnet.plist"),
    Path(".config/opencode/skills/obsidian-tldraw"),
    Path(".config/opencode/skills/ugreen-nas-docker-deploy"),
)


def configured_profile() -> str:
    """Return the environment override or machine-local profile."""
    profile = os.environ.get("DOTFILES_PROFILE", "")
    if not profile:
        config_home = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
        profile_file = config_home / "dotfiles" / "profile"
        try:
            profile = profile_file.read_text(encoding="utf-8").splitlines()[0].strip()
        except (FileNotFoundError, IndexError, OSError):
            profile = "personal"
    if profile not in PROFILES:
        raise ValueError(
            f"invalid dotfiles profile {profile!r}; expected one of {', '.join(PROFILES)}"
        )
    return profile


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
    parser.add_argument(
        "--profile",
        choices=PROFILES,
        help="machine profile (default: configured profile, then personal)",
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


def remove_inactive_links(
    files: Iterable[Path], destination_root: Path, dry_run: bool
) -> None:
    """Remove only stale symlinks that point back into this repository."""
    for relative in files:
        destination = destination_root / relative
        if not destination.is_symlink():
            continue
        try:
            destination.resolve(strict=False).relative_to(DOTFILES_DIR)
        except (OSError, ValueError):
            continue
        print(f"unlink  {destination} (not used by active profile)")
        if not dry_run:
            destination.unlink()


def link_files(
    files: Iterable[Tuple[Path, Path]],
    destination_root: Path,
    backup_root: Path,
    dry_run: bool,
    assume_yes: bool,
) -> int:
    failures = 0
    for relative, source in files:
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
    try:
        profile = args.profile or configured_profile()
    except ValueError as error:
        print(error, file=sys.stderr)
        return 2
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

    sources: Dict[Path, Path] = {}
    for relative in files:
        if profile == "work" and any(
            relative == excluded or excluded in relative.parents
            for excluded in WORK_EXCLUDES
        ):
            continue
        sources[relative] = source_root / relative

    source_relative = source_root.relative_to(DOTFILES_DIR)
    profile_root = DOTFILES_DIR / "profiles" / profile / source_relative
    if profile_root.is_dir():
        try:
            for relative in tracked_files(profile_root):
                sources[relative] = profile_root / relative
        except (ValueError, subprocess.CalledProcessError) as error:
            print(f"cannot list profile files: {error}", file=sys.stderr)
            return 2

    remove_inactive_links(sorted(set(files) - set(sources)), destination_root, args.dry_run)

    failures = link_files(
        sorted(sources.items()),
        destination_root,
        backup_root,
        args.dry_run,
        args.yes,
    )
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
