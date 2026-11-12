---
name: validation
description: Validate ZNix syntax, static policy, all output evaluations, and separately requested builds without activation.
---

# Validate ZNix

1. Read `AGENTS.md` and [docs/operations.md](../../../docs/operations.md).
   From the repository root, use the locked development tools:

   ```sh
   nix develop
   ./scripts/check.sh all
   ./scripts/check.sh all --base <review-base>
   ```

2. `check.sh syntax` parses tracked and untracked Nix/Bash files; `static`
   checks changed Nix formatting, ShellCheck, and workflow tests; `eval`
   resolves every registered NixOS and Home Manager derivation. Add new flake
   files to Git by exact reviewed path before evaluation: Git flakes cannot see
   untracked imports. Never replace that with `git add .`.
3. Run flake-level checks when needed:

   ```sh
   nix flake check --no-build --no-update-lock-file
   nix flake check --no-update-lock-file
   ```

4. Evaluation does not compile outputs. For a separate build, run the requested
   `nix build ... --no-link` or dry-build command from operations documentation.
   Neither evaluates an activation permission.
5. Report commands, outputs, and limits precisely; do not describe evaluation
   as a build or a build as proof of boot/runtime behavior.
