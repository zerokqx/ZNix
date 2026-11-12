---
name: conventional-commit
description: Review repository changes, safely stage intended files, and create a Conventional Commit. Use when asked to commit; accepts en or ru for the commit message language.
---

# Conventional Commit

Create a commit from the intended worktree changes. The user may provide `en` or `ru`; use that language for the subject and any body. If omitted, follow the repository's recent commit language.

1. Check `git status --short`, the staged diff, and the unstaged diff. Review the diff and untracked file names/content briefly to understand scope and spot credentials, tokens, private keys, `.env` files, or other private data. Do not print secret values in summaries.
2. Stage intended changes, including relevant untracked files, while excluding secrets and private/local data. Do not blindly run `git add .` or `git add -A`. Preserve unrelated existing staged changes: if the index already contains work outside this request, do not commit it together; ask the user how to handle the mixed staged set. Never silently unstage or overwrite the user's index state.
3. Inspect the complete staged diff, verify no secrets or unrelated files were added, and run `git diff --cached --check`. If the changes contain a clear, directly relevant check, run it; do not expand into unrelated validation.
4. Write a concise Conventional Commit subject using `<type>(optional-scope): <description>`, choosing a fitting type such as `feat`, `fix`, `docs`, `refactor`, `test`, `build`, `ci`, `perf`, or `chore`. Keep the description imperative and lower-case where natural for the requested language. Use a body only when it adds useful context.
5. Create the commit, then inspect `git status --short` and the latest commit to confirm the result. Report the commit hash and subject, checks run, and any remaining worktree changes.

Stop before committing if the intended scope is unclear, suspected secret content cannot be confidently excluded, or the staged set combines unrelated work that cannot be safely separated without changing the user's index. Explain the concrete issue and ask only what is needed to proceed.
