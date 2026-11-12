#!/usr/bin/env python3
"""Install repository skills for agents that need an explicit skill directory."""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import sys


SKILLS = (
    "install",
    "architecture",
    "desktop",
    "desktop-backgrounds",
    "hosts",
    "packages",
    "stylix",
    "nixvim",
    "validation",
    "deployment",
    "refactoring",
)


def within(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
    except ValueError:
        return False
    return True


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", type=Path, default=Path.cwd(), help="repository root (default: current directory)")
    parser.add_argument("--environment", choices=("codex", "claude", "other"), required=True)
    parser.add_argument("--target", type=Path, help="repo-relative skill directory for another agent")
    return parser.parse_args()


def resolved(path: Path, label: str) -> Path:
    try:
        return path.resolve(strict=False)
    except (OSError, RuntimeError) as error:
        raise ValueError(f"cannot resolve {label}: {error}") from error


def reject_broken_links(path: Path, label: str) -> None:
    current = path
    while current != current.parent:
        if os.path.lexists(current) and not current.exists():
            raise ValueError(f"{label} is dangling or cyclic: {current}")
        current = current.parent


def checked_target(repo: Path, source: Path, target_arg: Path | None) -> Path:
    if target_arg is None:
        raise ValueError("--target is required for this environment")
    if target_arg.is_absolute():
        raise ValueError("--target must be relative to the repository")

    raw_target = repo / target_arg
    reject_broken_links(raw_target, "--target")
    target = resolved(raw_target, "--target")
    if not within(target, repo):
        raise ValueError("--target must stay inside the repository")
    if within(target, source) or within(source, target):
        raise ValueError("--target must not be the skills source, inside it, or an ancestor of it")
    return target


def validate_source(repo: Path, source: Path) -> Path:
    reject_broken_links(source, "skills source")
    source = resolved(source, "skills source")
    if not within(source, repo):
        raise ValueError("skills source must stay inside the repository")
    missing = [name for name in SKILLS if not (source / name / "SKILL.md").is_file()]
    if missing:
        raise ValueError(f"missing skill definitions: {', '.join(missing)}")
    return source


def validate_links(source: Path, target: Path) -> list[tuple[Path, Path]]:
    current = target
    while current != current.parent:
        if os.path.lexists(current) and not current.is_dir():
            raise ValueError(f"skill target requires a directory: {current}")
        current = current.parent

    links = [(target / name, source / name) for name in SKILLS]
    conflicts: list[Path] = []
    for destination, expected in links:
        if not os.path.lexists(destination):
            continue
        if destination.is_symlink() and resolved(destination, str(destination)) == expected:
            continue
        conflicts.append(destination)
    if conflicts:
        names = ", ".join(str(path) for path in conflicts)
        raise ValueError(f"refusing to overwrite existing paths: {names}")
    return links


def install_links(source: Path, target: Path) -> None:
    links = validate_links(source, target)
    target.mkdir(parents=True, exist_ok=True)
    for destination, expected in links:
        if os.path.lexists(destination):
            continue
        relative = os.path.relpath(expected, destination.parent)
        destination.symlink_to(relative, target_is_directory=True)


def main() -> int:
    args = parse_args()
    try:
        repo = resolved(args.repo, "--repo")
        source = validate_source(repo, repo / ".agents" / "skills")
        environment = args.environment
        if environment == "codex":
            if args.target:
                raise ValueError("Codex discovers .agents/skills natively; use --environment other for a compatibility target")
            print("Codex native discovery validated at .agents/skills; no links created.")
            return 0
        if environment == "claude" and args.target:
            raise ValueError("Claude uses .claude/skills; use --environment other for a custom target")
        target_arg = Path(".claude/skills") if environment == "claude" else args.target
        target = checked_target(repo, source, target_arg)
        install_links(source, target)
        print(f"Installed {len(SKILLS)} relative skill links in {target.relative_to(repo)} for {environment}.")
        return 0
    except (ValueError, OSError, RuntimeError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
