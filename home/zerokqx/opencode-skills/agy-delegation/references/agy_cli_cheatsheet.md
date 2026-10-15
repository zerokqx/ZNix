# Antigravity CLI Reference for Delegation

## CLI Flags Reference

| Flag | Description | Values / Usage |
| :--- | :--- | :--- |
| `-p`, `--print` | Run non-interactively and output result | e.g. `agy -p "prompt"` |
| `--output-format` | Output format | `text`, `json`, `stream-json` |
| `--mode` | Agent execution mode | `plan` (read-only/planning), `accept-edits` (direct workspace editing) |
| `--dangerously-skip-permissions` | Auto-approve tool calls | Used with `--mode accept-edits` for unattended tasks |
| `--add-dir` | Add directory to active workspace | `--add-dir /path/to/project` |
| `--model` | Select active model | e.g. `"Gemini 3.8 Flash (Medium)"` |
| `--effort` | Reasoning depth | `low`, `medium`, `high`, `max` |
| `--conversation` | Attach/resume session ID | `--conversation <uuid>` |
| `--continue` | Continue most recent session | `-c` |
| `--print-timeout` | Timeout for print execution | e.g. `120s` (0 is indefinite) |

---

## Delegation Patterns

### 1. Read-Only Consultation (Mode: `consult`)
Use when Codex needs architectural advice, alternative perspective, large-context exploration, or code review from Gemini/Antigravity without modifying local files:

```bash
python3 ~/.codex/skills/agy-delegation/scripts/delegate_agy.py \
  --mode consult \
  -p "Analyze this database schema and propose indexing strategy" \
  --context-files schema.prisma src/db.ts
```

### 2. Workspace Execution (Mode: `exec`)
Use when Codex delegates direct file modifications, automated refactoring, or multi-file boilerplate generation to Antigravity:

```bash
python3 ~/.codex/skills/agy-delegation/scripts/delegate_agy.py \
  --mode exec \
  -C /path/to/repo \
  -p "Implement unit tests for all endpoints in src/api/"
```

### 3. Continuation / Multi-Turn
To ask a follow-up or continue an existing conversation:

```bash
agy -p "Now optimize the function for memory allocations" --continue
```
