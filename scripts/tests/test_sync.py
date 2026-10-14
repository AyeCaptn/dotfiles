"""Exercise dotfile links without changing the real home directory."""

import contextlib
import io
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
import sync as dotfiles_sync


class LinkFilesTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name).resolve()
        self.home = self.root / "home"
        self.home.mkdir()
        self.source = self.root / "profile" / "opencode.jsonc"
        self.source.parent.mkdir()
        self.source.write_text('{"model": "personal"}\n')
        self.relative = Path(".config/opencode/opencode.jsonc")
        self.target = self.home / self.relative
        self.backup = self.root / "backup"

    def link(self, dry_run=False):
        with contextlib.redirect_stdout(io.StringIO()):
            return dotfiles_sync.link_files(
                [(self.relative, self.source)],
                self.home,
                self.backup,
                dry_run,
                True,
            )

    def test_regular_home_links_readable_profile(self):
        self.link()

        self.assertEqual(self.target.read_text(), '{"model": "personal"}\n')

    def test_symlinked_config_links_readable_profile(self):
        shared = self.root / "shared"
        (shared / "opencode").mkdir(parents=True)
        (self.home / ".config").symlink_to(shared, target_is_directory=True)

        self.link()

        self.assertEqual(self.target.read_text(), '{"model": "personal"}\n')

    def test_symlinked_config_with_missing_subdirectory_links_readable_profile(self):
        shared = self.root / "shared"
        shared.mkdir()
        (self.home / ".config").symlink_to(shared, target_is_directory=True)

        self.link()

        self.assertEqual(self.target.read_text(), '{"model": "personal"}\n')

    def test_replaced_file_is_backed_up(self):
        self.target.parent.mkdir(parents=True)
        self.target.write_text("local preferences\n")

        self.link()

        self.assertEqual(
            (self.backup / self.relative).read_text(), "local preferences\n"
        )

    def test_dry_run_does_not_create_link(self):
        self.link(dry_run=True)

        self.assertFalse(self.target.is_symlink())


if __name__ == "__main__":
    unittest.main()
