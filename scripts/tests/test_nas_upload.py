"""Exercise the upload command without connecting to the NAS."""

import json
import os
from pathlib import Path
import shlex
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[2] / "bin" / "nas-upload"


class NasUploadTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name).resolve()
        self.file = self.root / "Movie's title; $test.mkv"
        self.file.write_text("test movie")
        self.key = self.root / "key with spaces"
        self.key.touch()
        self.capture = self.root / "arguments.json"
        commands = self.root / "bin"
        commands.mkdir()
        caffeinate = commands / "caffeinate"
        caffeinate.write_text('#!/bin/sh\nshift\nexec "$@"\n')
        caffeinate.chmod(0o755)
        rsync = commands / "rsync"
        rsync.write_text(
            "#!/usr/bin/env python3\n"
            "import json, os, pathlib, sys\n"
            "pathlib.Path(os.environ['CAPTURE']).write_text(json.dumps(sys.argv[1:]))\n"
            "sys.exit(int(os.environ.get('RSYNC_EXIT', '0')))\n"
        )
        rsync.chmod(0o755)
        self.env = {
            **os.environ,
            "PATH": f"{commands}:{os.environ['PATH']}",
            "NAS_HOST": "192.168.1.145",
            "NAS_PORT": "2222",
            "NAS_USER": "upload",
            "NAS_UPLOAD_DIR": ".",
            "NAS_SSH_KEY": str(self.key),
            "CAPTURE": str(self.capture),
        }

    def run_upload(self, *args):
        return subprocess.run(
            ["/bin/bash", str(SCRIPT), *map(str, args)],
            env=self.env,
            capture_output=True,
            text=True,
            check=False,
        )

    def test_upload_uses_resumable_rsync_to_lan_destination(self):
        self.run_upload(self.file)
        args = json.loads(self.capture.read_text())

        self.assertEqual(
            args,
            [
                "-tv",
                "--progress",
                "--stats",
                "--partial-dir=.rsync-partial",
                "--timeout=120",
                "-e",
                f"ssh -T -p 2222 -i {self.root}/key\\ with\\ spaces "
                "-o IdentitiesOnly=yes -o BatchMode=yes "
                "-o StrictHostKeyChecking=yes -o ConnectTimeout=10 "
                "-o ServerAliveInterval=15 -o ServerAliveCountMax=3",
                "--",
                str(self.file),
                "upload@192.168.1.145:.",
            ],
        )

    def test_dry_run_is_forwarded(self):
        self.run_upload("--dry-run", self.file)
        args = json.loads(self.capture.read_text())

        self.assertIn("--dry-run", args)

    def test_destination_with_shell_characters_is_one_remote_argument(self):
        destination = "Movie's folder; $test"
        self.run_upload(self.file, destination)
        remote = json.loads(self.capture.read_text())[-1].split(":", 1)[1]

        self.assertEqual(shlex.split(remote), [destination])

    def test_dot_slash_destination_is_normalized_for_rrsync(self):
        self.run_upload(self.file, "./")
        remote = json.loads(self.capture.read_text())[-1]

        self.assertEqual(remote, "upload@192.168.1.145:.")

    def test_missing_file_is_rejected(self):
        result = self.run_upload(self.root / "missing.mkv")

        self.assertEqual(result.returncode, 66)

    def test_absolute_destination_is_rejected(self):
        result = self.run_upload(self.file, "/volume1/media/movies")

        self.assertEqual(result.returncode, 64)

    def test_parent_traversal_is_rejected(self):
        result = self.run_upload(self.file, "incoming/../../elsewhere")

        self.assertEqual(result.returncode, 64)

    def test_invalid_port_is_rejected(self):
        self.env["NAS_PORT"] = "2222 -o ProxyCommand=bad"
        result = self.run_upload(self.file)

        self.assertEqual(result.returncode, 64)

    def test_missing_key_is_rejected(self):
        self.key.unlink()
        result = self.run_upload(self.file)

        self.assertEqual(result.returncode, 66)

    def test_transfer_failure_is_propagated(self):
        self.env["RSYNC_EXIT"] = "12"
        result = self.run_upload(self.file)

        self.assertEqual(result.returncode, 12)

    def test_help_does_not_start_a_transfer(self):
        self.run_upload("--help")

        self.assertFalse(self.capture.exists())


if __name__ == "__main__":
    unittest.main()
