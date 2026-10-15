#!/usr/bin/env python3
"""
delegate_agy.py - Helper script for OpenAI Codex CLI to delegate tasks to Google Antigravity (agy).

Usage:
  python3 delegate_agy.py --mode consult -p "Analyze this architecture and suggest optimizations"
  python3 delegate_agy.py --mode exec -p "Refactor the authentication middleware" -C /path/to/repo
  python3 delegate_agy.py --mode consult -p "Review this implementation" --context-files src/auth.ts
"""

import argparse
import json
import os
import subprocess
import sys
import tempfile
import time


def build_augmented_prompt(base_prompt: str, context_files: list[str]) -> str:
    if not context_files:
        return base_prompt

    sections = [base_prompt, "\n\n### Attached Context Files:\n"]
    for file_path in context_files:
        abs_path = os.path.abspath(file_path)
        if not os.path.exists(abs_path):
            sections.append(f"\n--- File: {abs_path} (NOT FOUND) ---\n")
            continue
        try:
            with open(abs_path, "r", encoding="utf-8", errors="replace") as f:
                content = f.read()
            sections.append(f"\n--- File: {abs_path} ---\n```\n{content}\n```\n")
        except Exception as e:
            sections.append(f"\n--- File: {abs_path} (Error reading: {e}) ---\n")

    return "".join(sections)


def run_agy(
    prompt: str,
    mode: str = "consult",
    model: str | None = None,
    workdir: str | None = None,
    output_file: str | None = None,
    context_files: list[str] | None = None,
    conversation_id: str | None = None,
    effort: str | None = None,
    timeout: int = 600,
    as_json: bool = False,
    extra_args: list[str] | None = None,
) -> int:
    target_workdir = os.path.abspath(workdir or os.getcwd())
    augmented_prompt = build_augmented_prompt(prompt, context_files or [])

    cmd = [
        "agy",
        "-p",
        augmented_prompt,
        "--output-format",
        "text",
    ]

    # Workspace directory
    cmd.extend(["--add-dir", target_workdir])

    # Mode mapping
    if mode == "consult":
        # Consultative / read-only: run in sandbox / plan mode so it doesn't modify files directly
        cmd.extend(["--mode", "plan"])
    elif mode == "exec":
        # Direct execution: accept edits and skip confirmations
        cmd.extend(["--mode", "accept-edits", "--dangerously-skip-permissions"])

    if model:
        cmd.extend(["--model", model])

    if effort:
        cmd.extend(["--effort", effort])

    if conversation_id:
        cmd.extend(["--conversation", conversation_id])

    if extra_args:
        cmd.extend(extra_args)

    start_time = time.time()
    try:
        process = subprocess.run(
            cmd,
            cwd=target_workdir,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=timeout,
        )
        duration = round(time.time() - start_time, 2)
        response_text = process.stdout.strip()

        # If user specified output_file, write response there
        if output_file and response_text:
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(response_text)

        if as_json:
            result = {
                "success": process.returncode == 0,
                "exit_code": process.returncode,
                "duration_seconds": duration,
                "model": model,
                "mode": mode,
                "response": response_text,
                "stdout": process.stdout,
                "stderr": process.stderr,
            }
            print(json.dumps(result, ensure_ascii=False, indent=2))
        else:
            if response_text:
                print(response_text)
            if process.returncode != 0:
                print(
                    f"\n[Antigravity CLI Warning/Error (exit code {process.returncode})]:",
                    file=sys.stderr,
                )
                if process.stderr:
                    print(process.stderr, file=sys.stderr)

        return process.returncode

    except subprocess.TimeoutExpired:
        msg = f"Antigravity CLI execution timed out after {timeout} seconds."
        if as_json:
            print(json.dumps({"success": False, "error": msg, "exit_code": -1}))
        else:
            print(f"Error: {msg}", file=sys.stderr)
        return 124
    except FileNotFoundError:
        msg = "Antigravity binary 'agy' not found in PATH. Verify ~/.local/bin/agy is available."
        if as_json:
            print(json.dumps({"success": False, "error": msg, "exit_code": 127}))
        else:
            print(f"Error: {msg}", file=sys.stderr)
        return 127


def main():
    parser = argparse.ArgumentParser(
        description="Delegate tasks from OpenAI Codex CLI to Google Antigravity (agy)."
    )
    prompt_group = parser.add_mutually_exclusive_group()
    prompt_group.add_argument(
        "-p", "--prompt", type=str, help="Prompt instruction to pass to Antigravity"
    )
    prompt_group.add_argument(
        "-f", "--prompt-file", type=str, help="Path to file containing prompt text"
    )

    parser.add_argument(
        "--mode",
        choices=["consult", "exec"],
        default="consult",
        help="Delegation mode: consult (plan/read-only reasoning), exec (autonomous workspace edits)",
    )
    parser.add_argument(
        "-m",
        "--model",
        type=str,
        help="Model override (e.g. 'Gemini 3.8 Flash (Medium)', 'gemini-2.5-pro')",
    )
    parser.add_argument(
        "--effort",
        choices=["low", "medium", "high", "max"],
        help="Reasoning effort level for the Antigravity agent",
    )
    parser.add_argument(
        "-C",
        "--cd",
        type=str,
        dest="workdir",
        help="Working directory for Antigravity workspace",
    )
    parser.add_argument(
        "-o", "--output", type=str, help="Path to save the model response"
    )
    parser.add_argument(
        "--context-files",
        nargs="*",
        default=[],
        help="File paths to read and include into the prompt context",
    )
    parser.add_argument(
        "--conversation",
        type=str,
        dest="conversation_id",
        help="Resume or attach to an existing Antigravity conversation ID",
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=600,
        help="Timeout in seconds for agy run (default: 600s)",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output structured JSON containing status and response",
    )

    args, unknown = parser.parse_known_args()

    prompt_text = ""
    if args.prompt:
        prompt_text = args.prompt
    elif args.prompt_file:
        with open(args.prompt_file, "r", encoding="utf-8") as f:
            prompt_text = f.read()
    else:
        if not sys.stdin.isatty():
            prompt_text = sys.stdin.read()
        else:
            parser.error("A prompt is required (via -p, -f, or stdin).")

    exit_code = run_agy(
        prompt=prompt_text,
        mode=args.mode,
        model=args.model,
        workdir=args.workdir,
        output_file=args.output,
        context_files=args.context_files,
        conversation_id=args.conversation_id,
        effort=args.effort,
        timeout=args.timeout,
        as_json=args.json,
        extra_args=unknown,
    )
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
