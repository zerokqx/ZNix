---
name: validation
description: Validate ZNix syntax, static policy, all output evaluations, and separately requested builds without activation.
---

# Validate ZNix

1. Read `AGENTS.md` and [docs/operations.md](../../../docs/operations.md).
   From the repository root, use the locked development tools:

   ```sh
   nix develop -c bash
   nix fmt -- <changed-files>
   ./scripts/check.sh all
   ./scripts/check.sh all --base <review-base>
   ```

2. `nix fmt` changes the named files through the project treefmt formatter.
   `check.sh syntax` parses tracked and untracked Nix/Bash files; `static`
   runs treefmt on temporary copies of changed regular source files, checks
   `git diff --check`, ShellCheck, and workflow tests; `eval`
   resolves every registered NixOS and Home Manager derivation. Add new flake
   files to Git by exact reviewed path before evaluation: Git flakes cannot see
   untracked imports. Never replace that with `git add .`.
3. Run flake-level checks when needed:

   ```sh
   nix flake check --no-build --no-update-lock-file
   nix flake check --no-update-lock-file
   ```

4. The focused firewall VM test is deliberately separate from `flake check`:

   ```sh
   nix build .#dev-ports-test --no-link --no-update-lock-file
   ```

   It tests `znix.dev.ports` in two small guests; it does not validate a physical
   host. Evaluation does not compile outputs. For a separate build, run the requested
   `nix build ... --no-link` or dry-build command from operations documentation.
   Neither evaluates an activation permission.

5. Report commands, outputs, and limits precisely; do not describe evaluation
   as a build or a build as proof of boot/runtime behavior.
