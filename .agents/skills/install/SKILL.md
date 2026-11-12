---
name: install
description: Install this repository's agent skills for Codex, Claude Code, or another repo-local agent directory.
---

# Install ZNix agent skills

1. Read `AGENTS.md`. The canonical source is `.agents/skills/`; do not copy it into a global agent directory or edit global agent settings.
2. Select the runtime explicitly. This is the reliable form:

   ```sh
   python3 scripts/install-skills.py --environment codex
   python3 scripts/install-skills.py --environment claude
   python3 scripts/install-skills.py --environment other --target .agent/skills
   ```

   Select the runtime from the current agent/session identity. If it is unknown,
   ask which target to install for; do not infer it from installed `.claude/`
   directories or ambient environment variables. `codex` only validates native
   `.agents/skills` discovery and writes nothing. `claude` creates
   `.claude/skills/<skill>` relative symlinks. `other` requires a repo-relative
   target.
3. The installer checks every required skill before it writes. It is idempotent, preserves correct links, and refuses existing files, directories, wrong or dangling links. It also rejects paths outside the repository and links that would point into the source or one of its ancestors.
4. Verify without needing a network or a running agent:

   ```sh
   PYTHONDONTWRITEBYTECODE=1 python3 -m unittest tests/test_install_skills.py
   ```

Use `.codex/skills` compatibility links only for a tool that demonstrably cannot discover `.agents/skills`; pass it explicitly as `other --target .codex/skills`.
