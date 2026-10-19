"""GPG agent installation regressions using an isolated home directory."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "dotbot/lib/pyyaml/lib"))
import yaml  # noqa: E402 -- use Dotbot's bundled PyYAML


class GpgConfigTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name).resolve()
        self.config = self.home / ".gnupg/gpg-agent.conf"
        self.bin_dir = self.home / "tools with spaces"
        self.bin_dir.mkdir()
        self.pinentry = self.bin_dir / "pinentry-mac"
        self.pinentry.write_text("#!/bin/sh\nexit 0\n")
        self.pinentry.chmod(0o755)
        self.uname = self.bin_dir / "uname"
        self.uname.write_text("#!/bin/sh\nprintf 'Darwin\\n'\n")
        self.uname.chmod(0o755)
        gpgconf = self.bin_dir / "gpgconf"
        gpgconf.write_text(
            '#!/bin/sh\nprintf "%s\\n" "$@" > "$HOME/reload.log"\n'
        )
        gpgconf.chmod(0o755)
        self.env = dict(
            os.environ,
            HOME=str(self.home),
            GNUPGHOME=str(self.config.parent),
            PATH=str(self.bin_dir) + os.pathsep + os.environ["PATH"],
        )
        self.template = (ROOT / "gnupg/gpg-agent.conf").read_text()

    def run_installer(self):
        return subprocess.run(
            ["bash", str(ROOT / "gnupg/install.sh")],
            env=self.env,
            capture_output=True,
            text=True,
        )

    def assert_installed(self):
        result = self.run_installer()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        contents = self.config.read_text()
        self.assertTrue(contents.startswith(self.template))
        self.assertEqual(
            [line for line in contents.splitlines()
             if line.startswith("pinentry-program ")],
            ["pinentry-program " + str(self.pinentry)],
        )

    def test_macos_installs_defaults_and_detects_pinentry(self):
        self.assert_installed()
        self.assertFalse(self.config.is_symlink())
        self.assertEqual(self.config.stat().st_mode & 0o777, 0o600)
        self.assertEqual(
            (self.home / "reload.log").read_text().splitlines(),
            ["--homedir", str(self.config.parent), "--reload", "gpg-agent"],
        )

    def test_existing_options_are_merged_and_original_is_backed_up(self):
        self.config.parent.mkdir()
        original = (
            "# Local settings\n"
            "enable-ssh-support\n"
            "default-cache-ttl 10\n"
            "pinentry-program /old/pinentry\n"
        )
        self.config.write_text(original)
        self.assert_installed()
        contents = self.config.read_text()
        self.assertIn("enable-ssh-support\n", contents)
        self.assertNotIn("default-cache-ttl 10\n", contents)
        backups = list(self.config.parent.glob("gpg-agent.conf.backup.*"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), original)

    def test_repeat_install_does_not_rewrite_or_duplicate(self):
        self.assert_installed()
        stat = self.config.stat()
        self.assert_installed()
        self.assertEqual(self.config.stat().st_mtime_ns, stat.st_mtime_ns)
        self.assertEqual(self.config.stat().st_ino, stat.st_ino)
        self.assertEqual(
            list(self.config.parent.glob("gpg-agent.conf.backup.*")), []
        )

    def test_existing_symlink_does_not_modify_repository_template(self):
        self.config.parent.mkdir()
        self.config.symlink_to(ROOT / "gnupg/gpg-agent.conf")
        self.assert_installed()
        self.assertFalse(self.config.is_symlink())
        self.assertEqual(
            (ROOT / "gnupg/gpg-agent.conf").read_text(), self.template
        )

    def test_broken_symlink_is_replaced(self):
        self.config.parent.mkdir()
        self.config.symlink_to(self.home / "missing-config")
        self.assert_installed()
        self.assertFalse(self.config.is_symlink())

    def test_linux_installs_defaults_without_macos_pinentry(self):
        self.uname.write_text("#!/bin/sh\nprintf 'Linux\\n'\n")
        result = self.run_installer()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.read_text(), self.template)

    def test_missing_pinentry_fails_without_changing_existing_config(self):
        self.pinentry.unlink()
        self.env["PATH"] = str(self.bin_dir) + os.pathsep + "/usr/bin:/bin"
        self.config.parent.mkdir()
        self.config.write_text("enable-ssh-support\n")
        result = self.run_installer()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("pinentry-mac was not found", result.stderr)
        self.assertEqual(self.config.read_text(), "enable-ssh-support\n")

    def test_dotbot_installs_gpg_config_and_honors_dry_run(self):
        config = yaml.safe_load((ROOT / "install.conf.yaml").read_text())
        link = "~/.gnupg/gpg-agent.conf"
        self.assertFalse(any(link in task.get("link", {}) for task in config))
        command = next(
            item for task in config for item in task.get("shell", [])
            if isinstance(item, dict)
            and item.get("command") == "bash gnupg/install.sh"
        )
        config_path = self.home / "install.json"
        config_path.write_text(json.dumps([{"shell": [command]}]))
        args = [
            sys.executable, str(ROOT / "dotbot/bin/dotbot"),
            "-d", str(ROOT), "-c", str(config_path),
        ]
        for dry_run in (True, False):
            with self.subTest(dry_run=dry_run):
                result = subprocess.run(
                    args + (["--dry-run"] if dry_run else []),
                    env=self.env, capture_output=True, text=True,
                )
                self.assertEqual(
                    result.returncode, 0, result.stdout + result.stderr
                )
                self.assertEqual(self.config.exists(), not dry_run)


if __name__ == "__main__":
    unittest.main()
