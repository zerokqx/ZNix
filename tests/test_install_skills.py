from __future__ import annotations

import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


PROJECT = Path(__file__).resolve().parents[1]
INSTALLER = PROJECT / "scripts" / "install-skills.py"
SKILLS = (
    "install",
    "architecture",
    "desktop",
    "hosts",
    "packages",
    "stylix",
    "nixvim",
    "validation",
    "deployment",
    "refactoring",
)


class InstallSkillsTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()
        self.repo = Path(self.tempdir.name) / "repo"
        source = self.repo / ".agents" / "skills"
        source.mkdir(parents=True)
        for name in SKILLS:
            skill = source / name
            skill.mkdir()
            (skill / "SKILL.md").write_text("---\nname: test\ndescription: test\n---\n", encoding="utf-8")

    def tearDown(self) -> None:
        self.tempdir.cleanup()

    def invoke(self, *arguments: str, env: dict[str, str] | None = None) -> subprocess.CompletedProcess[str]:
        command_env = os.environ.copy()
        if env is not None:
            command_env.update(env)
        return subprocess.run(
            [sys.executable, str(INSTALLER), "--repo", str(self.repo), *arguments],
            text=True,
            capture_output=True,
            check=False,
            env=command_env,
        )

    def test_claude_links_are_relative_and_idempotent(self) -> None:
        first = self.invoke("--environment", "claude")
        second = self.invoke("--environment", "claude")
        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertEqual(second.returncode, 0, second.stderr)
        for name in SKILLS:
            link = self.repo / ".claude" / "skills" / name
            self.assertTrue(link.is_symlink())
            self.assertFalse(os.readlink(link).startswith("/"))
            self.assertEqual(link.resolve(), self.repo / ".agents" / "skills" / name)

    def test_existing_content_is_preserved_on_conflict(self) -> None:
        target = self.repo / ".claude" / "skills"
        target.mkdir(parents=True)
        conflict = target / "hosts"
        conflict.write_text("do not replace", encoding="utf-8")
        result = self.invoke("--environment", "claude")
        self.assertEqual(result.returncode, 2)
        self.assertEqual(conflict.read_text(encoding="utf-8"), "do not replace")
        self.assertFalse((target / "install").exists())

    def test_dangling_link_is_not_replaced(self) -> None:
        target = self.repo / ".claude" / "skills"
        target.mkdir(parents=True)
        conflict = target / "packages"
        conflict.symlink_to("missing-skill")
        result = self.invoke("--environment", "claude")
        self.assertEqual(result.returncode, 2)
        self.assertEqual(os.readlink(conflict), "missing-skill")
        self.assertFalse((target / "install").exists())

    def test_wrong_link_is_not_replaced(self) -> None:
        target = self.repo / ".claude" / "skills"
        target.mkdir(parents=True)
        conflict = target / "packages"
        conflict.symlink_to(self.repo / ".agents" / "skills" / "hosts")
        result = self.invoke("--environment", "claude")
        self.assertEqual(result.returncode, 2)
        self.assertEqual(conflict.resolve(), self.repo / ".agents" / "skills" / "hosts")
        self.assertFalse((target / "install").exists())

    def test_rejects_source_and_ancestor_targets_without_writes(self) -> None:
        for target in (".agents/skills/mirror", ".agents"):
            with self.subTest(target=target):
                result = self.invoke("--environment", "other", "--target", target)
                self.assertEqual(result.returncode, 2)
        self.assertFalse((self.repo / ".agents" / "install").exists())

    def test_rejects_target_escaping_repository(self) -> None:
        result = self.invoke("--environment", "other", "--target", "../outside")
        self.assertEqual(result.returncode, 2)

    def test_rejects_aliases_into_source_or_its_ancestor(self) -> None:
        alias = self.repo / "alias"
        alias.symlink_to(".agents", target_is_directory=True)
        for target in ("alias", "alias/skills/mirror"):
            with self.subTest(target=target):
                result = self.invoke("--environment", "other", "--target", target)
                self.assertEqual(result.returncode, 2)

    def test_rejects_target_parent_linked_outside_repository(self) -> None:
        outside = Path(self.tempdir.name) / "outside"
        outside.mkdir()
        (self.repo / ".claude").symlink_to(outside, target_is_directory=True)
        result = self.invoke("--environment", "claude")
        self.assertEqual(result.returncode, 2)
        self.assertFalse((outside / "skills").exists())

    def test_rejects_symlink_loop_in_source(self) -> None:
        source_parent = self.repo / ".agents"
        shutil.rmtree(source_parent / "skills")
        (source_parent / "skills").symlink_to("skills", target_is_directory=True)
        result = self.invoke("--environment", "codex")
        self.assertEqual(result.returncode, 2)
        self.assertIn("skills source is dangling or cyclic", result.stderr)

    def test_relative_links_survive_repository_relocation(self) -> None:
        result = self.invoke("--environment", "claude")
        self.assertEqual(result.returncode, 0, result.stderr)
        moved = Path(self.tempdir.name) / "moved-repo"
        shutil.copytree(self.repo, moved, symlinks=True)
        link = moved / ".claude" / "skills" / "install"
        self.assertEqual(link.resolve(), moved / ".agents" / "skills" / "install")

    def test_codex_validates_native_source_without_writing(self) -> None:
        result = self.invoke("--environment", "codex")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.repo / ".codex").exists())

    def test_missing_environment_fails_without_writes(self) -> None:
        result = self.invoke()
        self.assertEqual(result.returncode, 2)
        self.assertIn("--environment", result.stderr)
        self.assertFalse((self.repo / ".claude").exists())


if __name__ == "__main__":
    unittest.main()
