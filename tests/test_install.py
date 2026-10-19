"""Run installer regressions with python3 -m unittest discover -s tests."""

import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class PythonPackagesTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name).resolve()
        self.package_dir = self.directory / "dotfiles' packages"
        self.package_dir.mkdir()
        self.script = self.package_dir / "pythonpackages.zsh"
        shutil.copyfile(ROOT / "pypackages/pythonpackages.zsh", self.script)
        (self.package_dir / "requirements.txt").write_text("flake8\n")
        self.cwd = self.directory / "other directory"
        self.cwd.mkdir()
        self.log = self.directory / "pip.jsonl"
        helper = self.directory / "python_stub.py"
        helper.write_text(
            "import json, os, sys\n"
            "if sys.argv[1] == '-c':\n"
            "    if os.environ.get('FAIL_RELPATH'):\n"
            "        sys.exit(7)\n"
            "    os.execv(sys.executable, [sys.executable] + sys.argv[1:])\n"
            "with open(os.environ['PIP_LOG'], 'a') as log:\n"
            "    log.write(json.dumps(sys.argv[1:]) + '\\n')\n"
            "if '--break-system-packages' in sys.argv:\n"
            "    sys.exit(int(os.environ.get('PIP_RETRY_STATUS', '0')))\n"
            "print(os.environ.get('PIP_OUTPUT', 'installed'))\n"
            "sys.exit(int(os.environ.get('PIP_STATUS', '0')))\n"
        )
        bin_dir = self.directory / "bin"
        bin_dir.mkdir()
        python = bin_dir / "python3"
        python.write_text(
            "#!/bin/sh\nexec "
            + shlex.quote(sys.executable)
            + " "
            + shlex.quote(str(helper))
            + ' "$@"\n'
        )
        python.chmod(0o755)
        # Force the native Python branch on every host running these tests.
        uname = bin_dir / "uname"
        uname.write_text("#!/bin/sh\nprintf 'Darwin\\n'\n")
        uname.chmod(0o755)
        self.env = dict(
            os.environ, PATH=str(bin_dir) + os.pathsep + os.environ["PATH"]
        )
        self.env.update(PIP_LOG=str(self.log), OSTYPE="darwin")

    def run_installer(self, **env):
        return subprocess.run(
            ["zsh", "-f", str(self.script)],
            cwd=self.cwd,
            env=dict(self.env, **env),
            capture_output=True,
            text=True,
        )

    def pip_calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()]

    def test_requirements_path_with_spaces_quotes_and_parent_directory(self):
        result = self.run_installer()
        self.assertEqual(result.returncode, 0, result.stderr)
        args, = self.pip_calls()
        self.assertEqual(args[:4], ["-m", "pip", "install", "-r"])
        self.assertEqual(
            (self.cwd / args[4]).resolve(),
            self.package_dir / "requirements.txt",
        )
        self.assertIn("installed", result.stdout)
        self.assertEqual(result.stderr, "")

    def test_pip_failure_is_reported(self):
        result = self.run_installer(
            PIP_STATUS="3", PIP_OUTPUT="pip download failed"
        )
        self.assertEqual(result.returncode, 3)
        self.assertIn("pip download failed", result.stderr)
        self.assertEqual(len(self.pip_calls()), 1)

    def test_managed_environment_retries(self):
        result = self.run_installer(
            PIP_STATUS="1", PIP_OUTPUT="error: externally-managed-environment"
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        first, retry = self.pip_calls()
        self.assertEqual(
            retry, first[:3] + ["--break-system-packages"] + first[3:]
        )

    def test_retry_failure_is_reported(self):
        result = self.run_installer(
            PIP_STATUS="1",
            PIP_OUTPUT="error: externally-managed-environment",
            PIP_RETRY_STATUS="4",
        )
        self.assertEqual(result.returncode, 4)

    def test_path_failure_stops_before_pip(self):
        result = self.run_installer(FAIL_RELPATH="1")
        self.assertEqual(result.returncode, 7)
        self.assertFalse(self.log.exists())


if __name__ == "__main__":
    unittest.main()
