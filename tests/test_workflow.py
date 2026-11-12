import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"

FAKE_COMMAND = """import json
import os
from pathlib import Path
import sys

command = Path(sys.argv[0]).name
args = sys.argv[1:]
with open(os.environ["COMMAND_LOG"], "a") as log:
    log.write(json.dumps([command, args, os.getcwd()]) + "\\n")

if command == "hostname":
    print(os.environ.get("FAKE_HOSTNAME", "nixos-pc"))
elif command == "nix" and args[0] == "eval":
    registry = json.loads(os.environ["FAKE_REGISTRY"])
    if "builtins.attrNames" in args:
        if ".#nixosConfigurations" in args:
            print(json.dumps(list(registry)))
        else:
            print(os.environ["FAKE_HOMES"])
    elif "--json" in args:
        print(json.dumps(registry))
    elif os.environ.get("FAKE_FAIL") in args:
        sys.exit(1)
    else:
        print("/nix/store/example.drv")
elif command == "nix" and args[0] == "build" and "--out-link" in args:
    launcher = Path(args[args.index("--out-link") + 1]) / "bin" / "run-guest-vm"
    launcher.parent.mkdir(parents=True)
    launcher.write_text(Path(__file__).read_text())
    launcher.chmod(0o755)
elif command == "nixos-rebuild":
    sys.exit("invoke via sudo")
elif command == "treefmt":
    root = Path(args[args.index("--tree-root") + 1])
    for name in args[args.index("--") + 1:]:
        (root / name).write_text("formatted copy\\n")
    sys.exit(int(os.environ.get("FAKE_FORMAT_FAILURE", "0")))
"""


class WorkflowTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / "repo with spaces"
        self.root.mkdir()
        shutil.copytree(SCRIPTS, self.root / "scripts")
        self.bin = Path(self.temp.name) / "bin"
        self.bin.mkdir()
        for name in ("nix", "hostname", "sudo", "nixos-rebuild", "treefmt", "shellcheck"):
            fake = self.bin / name
            fake.write_text(f"#!{sys.executable}\n{FAKE_COMMAND}")
            fake.chmod(0o755)
        self.log = Path(self.temp.name) / "commands.log"
        self.env = os.environ | {
            "PATH": f"{self.bin}{os.pathsep}{os.environ['PATH']}",
            "COMMAND_LOG": str(self.log),
            "FAKE_REGISTRY": json.dumps(
                {"desktop": "nixos-pc", "laptop": "nixos-laptop", "noop": "nixos"}
            ),
            "FAKE_HOMES": json.dumps(["noop", "zerok", "zerokqx"]),
        }

    def git(self, *args):
        return subprocess.run(
            ["git", *args], cwd=self.root, check=True, capture_output=True, text=True
        ).stdout

    def run_script(self, name, *args):
        return subprocess.run(
            ["bash", str(self.root / "scripts" / name), *args],
            cwd=self.temp.name,
            env=self.env,
            capture_output=True,
            text=True,
        )

    def calls(self):
        records = [json.loads(line) for line in self.log.read_text().splitlines()]
        for command, args, directory in records:
            expected = Path(args[args.index("--tree-root") + 1]) if command == "treefmt" else self.root
            self.assertEqual(Path(directory), expected)
        return [(command, args) for command, args, _ in records]

    def test_default_build_uses_evaluated_hostname_mapping(self):
        for hostname, host in (
            ("nixos-pc", "desktop"),
            ("nixos-laptop", "laptop"),
            ("nixos", "noop"),
        ):
            with self.subTest(hostname=hostname):
                self.log.unlink(missing_ok=True)
                self.env["FAKE_HOSTNAME"] = hostname
                result = self.run_script("rebuild.sh")
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(
                    self.calls()[-1],
                    (
                        "nix",
                        ["build", "--no-update-lock-file", "--no-link", "--show-trace",
                         f'.#nixosConfigurations."{host}".config.system.build.toplevel'],
                    ),
                )
                self.assertEqual([command for command, _ in self.calls()], ["hostname", "nix", "nix"])

    def test_invalid_and_ambiguous_hosts_stop_before_build(self):
        self.env["FAKE_HOSTNAME"] = "nixos-pc"
        self.env["FAKE_REGISTRY"] = json.dumps({"desktop": "nixos-pc", "spare": "nixos-pc"})
        result = self.run_script("rebuild.sh", "switch")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Pass HOST explicitly", result.stderr)
        self.assertEqual([command for command, _ in self.calls()], ["hostname", "nix"])

        self.log.unlink()
        result = self.run_script("rebuild.sh", "switch", "unknown")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Unknown host", result.stderr)
        self.assertEqual([command for command, _ in self.calls()], ["nix"])

    def test_explicit_activation_modes_do_not_change_git_index(self):
        self.git("init", "-q")
        (self.root / "staged.txt").write_text("staged")
        (self.root / "unstaged.txt").write_text("unstaged")
        self.git("add", "--", "staged.txt")
        index = self.root / ".git" / "index"
        previous = index.read_bytes()
        for action in ("switch", "test"):
            with self.subTest(action=action):
                self.log.unlink(missing_ok=True)
                result = self.run_script("rebuild.sh", action, "laptop")
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(
                    self.calls()[-1],
                    ("sudo", ["nixos-rebuild", action, "--flake", ".#laptop",
                              "--no-update-lock-file", "--show-trace"]),
                )
                self.assertEqual(index.read_bytes(), previous)

    def test_vm_build_launches_guest_without_sudo(self):
        result = self.run_script("rebuild.sh", "vm", "desktop")
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.calls()
        self.assertEqual([command for command, _ in calls], ["nix", "nix", "run-guest-vm"])
        self.assertEqual(calls[1][1][-1], '.#nixosConfigurations."desktop".config.system.build.vm')

    def test_eval_resolves_each_registered_output_without_build_or_activation(self):
        self.env["FAKE_REGISTRY"] = json.dumps({"test-host": "my-pc", "noop": "nixos"})
        self.env["FAKE_HOMES"] = json.dumps(["test-home", "zerok"])
        result = self.run_script("check.sh", "eval")
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.calls()
        self.assertTrue(all(command == "nix" and args[0] == "eval" for command, args in calls))
        self.assertTrue(all("--no-update-lock-file" in args for _, args in calls))
        self.assertEqual(
            [line.split()[0] for line in result.stdout.splitlines()[1:]],
            ["nixosConfigurations.test-host", "nixosConfigurations.noop",
             "homeConfigurations.test-home", "homeConfigurations.zerok"],
        )

    def test_eval_stops_on_failure(self):
        self.env["FAKE_FAIL"] = '.#nixosConfigurations."laptop".config.system.build.toplevel.drvPath'
        result = self.run_script("check.sh", "eval")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Could not evaluate nixosConfigurations.laptop", result.stderr)
        self.assertEqual(len(self.calls()), 3)

    def prepare_formatting_fixture(self):
        self.git("init", "-q")
        for name in ("changed.nix", "unchanged.nix", "deleted.nix"):
            (self.root / name).write_text("{}")
        self.git("add", "--", "changed.nix", "unchanged.nix", "deleted.nix", "scripts")
        self.git("-c", "user.name=Test", "-c", "user.email=test@example.org", "commit", "-qm", "base")
        (self.root / "changed.nix").write_text("{ changed = true; }")
        (self.root / "deleted.nix").unlink()
        (self.root / "untracked.nix").write_text("{}")
        (self.root / "new file.md").write_text("# New file\n")
        (self.root / "link.nix").symlink_to("changed.nix")
        tests = self.root / "tests"
        tests.mkdir()
        (tests / "test_fixture.py").write_text(
            "import unittest\n\n"
            "class Fixture(unittest.TestCase):\n"
            "    def test_fixture(self):\n"
            "        self.assertTrue(True)\n"
        )
        return {
            name: (self.root / name).read_bytes()
            for name in ("changed.nix", "unchanged.nix", "untracked.nix", "new file.md", ".git/index")
        }

    def test_static_formats_changed_copies_and_preserves_tree_and_index(self):
        previous = self.prepare_formatting_fixture()
        result = self.run_script("check.sh", "static")
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = [args for command, args in self.calls() if command == "treefmt"]
        self.assertEqual(len(calls), 1)
        args = calls[0]
        self.assertEqual(
            args[args.index("--") + 1:],
            ["changed.nix", "new file.md", "untracked.nix"],
        )
        self.assertFalse(Path(args[args.index("--tree-root") + 1]).exists())
        for name, content in previous.items():
            self.assertEqual((self.root / name).read_bytes(), content, name)

    def test_static_format_failure_preserves_tree_and_index(self):
        previous = self.prepare_formatting_fixture()
        self.env["FAKE_FORMAT_FAILURE"] = "1"
        result = self.run_script("check.sh", "static")
        self.assertNotEqual(result.returncode, 0)
        calls = self.calls()
        self.assertEqual([command for command, _ in calls], ["treefmt"])
        args = calls[0][1]
        self.assertFalse(Path(args[args.index("--tree-root") + 1]).exists())
        for name, content in previous.items():
            self.assertEqual((self.root / name).read_bytes(), content, name)

    def test_static_rejects_conflict_markers_before_formatting(self):
        self.prepare_formatting_fixture()
        (self.root / "changed.nix").write_text("<<<<<<< HEAD\n{}\n=======\n{}\n>>>>>>> branch\n")
        result = self.run_script("check.sh", "static")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())

    def test_static_stops_when_file_enumeration_fails(self):
        self.prepare_formatting_fixture()
        git = self.bin / "git"
        git.write_text(
            f"#!{sys.executable}\nimport os, sys\n"
            "if sys.argv[1:2] == ['ls-files'] and '--others' in sys.argv: sys.exit(7)\n"
            f"os.execv({shutil.which('git')!r}, [{shutil.which('git')!r}, *sys.argv[1:]])\n"
        )
        git.chmod(0o755)
        result = self.run_script("check.sh", "static")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())


if __name__ == "__main__":
    unittest.main()
