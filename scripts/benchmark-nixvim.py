#!/usr/bin/env python3
"""Measure a built Nixvim executable with isolated editor state and fixtures."""

import argparse
import errno
import fcntl
import json
import os
from pathlib import Path
import pty
import re
import selectors
import signal
import statistics
import struct
import subprocess
import termios
import time

TERMINAL_REPLIES = {
    b"\x1b]11;?\x07": b"\x1b]11;rgb:1414/1616/1b1b\x07",
    b"\x1b[5n": b"\x1b[0n",
    b"\x1b[c": b"\x1b[?1;2c",
}

PROBE = r"""
local function files()
    local report = {
      version = tostring(vim.version()),
      vimruntime = vim.env.VIMRUNTIME,
      config = vim.env.VIMINIT and vim.env.VIMINIT:match([[(/nix/store/[^'"]+%.lua)]]),
      files = {},
    }
    for _, file in ipairs({"small.rs", "large.rs", "small.json", "large.json"}) do
      local start = vim.uv.hrtime()
      vim.cmd.edit(file)
      vim.cmd.redraw()
      local elapsed = (vim.uv.hrtime() - start) / 1e6
      local buf = vim.api.nvim_get_current_buf()
      report.files[file] = {
        edit_redraw_ms = elapsed,
        ft = vim.bo[buf].filetype,
        lines = vim.api.nvim_buf_line_count(buf),
        treesitter = vim.treesitter.highlighter.active[buf] ~= nil,
      }
    end
    local start = vim.uv.hrtime()
    for _ = 1, 25 do
      vim.cmd.buffer("small.rs")
      vim.cmd.redraw()
      vim.cmd.buffer("small.json")
      vim.cmd.redraw()
    end
    report.switch_redraw_ms = (vim.uv.hrtime() - start) / 1e6 / 50
    report.rss_kib = vim.uv.resident_set_memory() / 1024
    return report
end

local function folds()
    local report = {}
    vim.cmd.edit("fold.rs")
    local test_line = vim.fn.search("^mod tests", "nw")
    assert(vim.wait(1000, function() return vim.fn.foldlevel(test_line) > 0 end, 10),
      "Tree-sitter did not prepare the test module fold")
    -- Invalidate any cached test positions computed by the automatic fold.
    vim.bo.readonly = true
    vim.api.nvim_buf_set_lines(0, -1, -1, false, {"// edited"})
    local unfolded = vim.fn.foldclosed(test_line)
    local start = vim.uv.hrtime()
    vim.cmd.RustFoldTests()
    report.rust_fold_first_ms = (vim.uv.hrtime() - start) / 1e6
    assert(vim.fn.foldclosed(test_line) ~= unfolded, "RustFoldTests did not toggle the test module")
    start = vim.uv.hrtime()
    for _ = 1, 4 do
      vim.cmd.RustFoldTests()
    end
    report.rust_fold_repeat_ms = (vim.uv.hrtime() - start) / 1e6 / 4
    assert(vim.fn.foldclosed(test_line) ~= unfolded, "Repeated RustFoldTests changed fold parity")
    return report
end

vim.schedule(function()
  local probe = vim.env.ZNIX_PROBE_KIND == "fold" and folds or files
  local ok, result = xpcall(probe, debug.traceback)
  vim.fn.writefile({vim.json.encode(ok and result or {error = result})}, vim.env.ZNIX_RESULT)
  vim.cmd("qa!")
end)
"""

def environment(state, work):
    state.mkdir(mode=0o700, exist_ok=True)
    env = os.environ.copy()
    for name in (
        "NVIM", "NVIM_LISTEN_ADDRESS", "NVIM_APPNAME", "MYVIMRC", "VIM", "VIMRUNTIME",
        "VIMINIT", "EXINIT", "GVIMINIT", "LUA_PATH", "LUA_CPATH", "DISPLAY",
        "WAYLAND_DISPLAY", "HYPRLAND_INSTANCE_SIGNATURE", "DBUS_SESSION_BUS_ADDRESS",
    ):
        env.pop(name, None)
    env.update(HOME=str(state), PWD=str(work), TERM="xterm-256color",
               GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_NOSYSTEM="1")
    for kind in ("CONFIG_HOME", "DATA_HOME", "CACHE_HOME", "STATE_HOME", "RUNTIME_DIR"):
        path = state / kind.lower()
        path.mkdir(mode=0o700, exist_ok=True)
        env["XDG_" + kind] = str(path)
    return env


def run_editor(command, mode, env, work):
    if mode == "headless":
        result = subprocess.run(
            [command[0], "--headless", *command[1:]],
            cwd=work, env=env, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT, timeout=30, check=True,
        )
        return result.stdout
    master, slave = pty.openpty()
    try:
        fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 32, 100, 0, 0))
        with subprocess.Popen(command, stdin=slave, stdout=slave, stderr=slave,
                              cwd=work, env=env, start_new_session=True) as process:
            os.close(slave)
            slave = None
            output = bytearray()
            try:
                with selectors.DefaultSelector() as selector:
                    selector.register(master, selectors.EVENT_READ)
                    deadline = time.monotonic() + 30
                    while time.monotonic() < deadline:
                        if not selector.select(deadline - time.monotonic()):
                            break
                        try:
                            chunk = os.read(master, 65536)
                        except OSError as error:
                            if error.errno != errno.EIO:
                                raise
                            break
                        if not chunk:
                            break
                        # Answer the probes a terminal would answer. In particular,
                        # ignoring OSC 11 introduces Neovim's E1568 startup timeout.
                        tail = bytes(output[-8:])
                        for query, reply in TERMINAL_REPLIES.items():
                            for match in re.finditer(re.escape(query), tail + chunk):
                                if match.end() > len(tail):
                                    os.write(master, reply)
                        output.extend(chunk)
                    process.wait(timeout=max(deadline - time.monotonic(), 0.01))
            except (subprocess.TimeoutExpired, KeyboardInterrupt):
                os.killpg(process.pid, signal.SIGKILL)
                raise
            if process.returncode:
                raise subprocess.CalledProcessError(process.returncode, command, bytes(output))
            return bytes(output)
    finally:
        if slave is not None:
            os.close(slave)
        os.close(master)


def trace_event(trace, label):
    # TUI startup logs the UI client first and the embedded editor second.
    matches = re.findall(r"^\s*(\d+\.\d+)\s+.*:\s+" + re.escape(label) + r"$", trace, re.M)
    return float(matches[-1]) if matches else None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("nvim", type=lambda path: Path(path).absolute())
    parser.add_argument("output", type=lambda path: Path(path).absolute())
    parser.add_argument("--runs", type=int, default=7)
    args = parser.parse_args()
    if args.runs < 2:
        parser.error("--runs must be at least 2")
    args.output.mkdir()
    work = args.output / "fixtures"
    work.mkdir()
    for size, count in (("small", 20), ("large", 12000)):
        with (work / (size + ".rs")).open("w") as file:
            for i in range(count):
                file.write(f"fn calculate_{i}(input: u64) -> u64 {{\n"
                           "    let intermediate = input.saturating_mul(42);\n"
                           "    intermediate.saturating_add(1)\n}\n")
            file.write("#[cfg(test)]\nmod tests {\n    #[test]\n"
                       "    fn smoke() { assert_eq!(super::calculate_0(1), 43); }\n}\n")
        (work / (size + ".json")).write_text(json.dumps(
            [{"id": i, "title": "A representative JSON document", "enabled": True,
              "tags": ["one", "two", "three"], "nested": {"weight": i * 2}} for i in range(count)],
            indent=2,
        ) + "\n")
    with (work / "fold.rs").open("w") as file:
        for i in range(1000):
            file.write(f"fn calculate_{i}(input: u64) -> u64 {{\n"
                       "    let intermediate = input.saturating_mul(42);\n"
                       "    intermediate.saturating_add(1)\n}\n")
        file.write("#[cfg(test)]\nmod tests {\n")
        for i in range(100):
            file.write(f"    #[test]\n    fn smoke_{i}() {{\n"
                       "        assert_eq!(super::calculate_0(1), 43);\n    }\n")
        file.write("}\n")
    (args.output / "probe.lua").write_text(PROBE)

    startup = {}
    for mode in ("headless", "tui"):
        warm = args.output / (mode + "-warm-state")
        for cache in ("cold", "warm"):
            values = []
            for i in range(args.runs + (cache == "warm")):
                prefix = f"{mode}-{cache}-{i}"
                state = warm if cache == "warm" else args.output / (prefix + "-state")
                trace = args.output / (prefix + ".trace")
                output = run_editor(
                    [str(args.nvim), "-i", "NONE", "--startuptime", str(trace),
                     "+lua vim.defer_fn(function() vim.cmd('qa!') end, 100)"],
                    mode, environment(state, work), work,
                )
                (args.output / (prefix + ".log")).write_bytes(output)
                if b"E1568:" in output or b"Error detected while processing" in output:
                    raise RuntimeError(f"Editor startup error: {prefix}.log")
                trace_text = trace.read_text()
                started = trace_event(trace_text, "--- NVIM STARTED ---")
                if started is None:
                    raise RuntimeError(f"Missing startup event: {trace}")
                if cache != "warm" or i:
                    values.append({"startup_ms": started,
                                   "first_screen_ms": trace_event(trace_text, "first screen update")})
            startup[f"{mode}-{cache}"] = values

    runtime, folds = [], []
    for kind, samples in (("runtime", runtime), ("fold", folds)):
        for i in range(args.runs):
            env = environment(args.output / (kind + "-state"), work)
            result = args.output / f"{kind}-{i}.json"
            env.update(ZNIX_RESULT=str(result), ZNIX_PROBE=str(args.output / "probe.lua"),
                       ZNIX_PROBE_KIND=kind)
            output = run_editor(
                [str(args.nvim), "-i", "NONE", "+lua dofile(vim.env.ZNIX_PROBE)"],
                "tui", env, work,
            )
            (args.output / f"{kind}-{i}.log").write_bytes(output)
            sample = json.loads(result.read_text())
            if "error" in sample:
                raise RuntimeError(sample["error"])
            samples.append(sample)

    report = {
        "binary": str(args.nvim),
        "fixture_bytes": {path.name: path.stat().st_size for path in work.iterdir()},
        "startup": startup,
        "runtime": runtime,
        "folds": folds,
    }
    (args.output / "results.json").write_text(json.dumps(report, indent=2) + "\n")
    for mode, values in startup.items():
        print(mode, "startup median ms:", statistics.median(item["startup_ms"] for item in values))
    for file in runtime[0]["files"]:
        print(file, "edit+redraw median ms:",
              statistics.median(item["files"][file]["edit_redraw_ms"] for item in runtime))
    print("switch+redraw median ms:", statistics.median(item["switch_redraw_ms"] for item in runtime))
    print("RSS median KiB:", statistics.median(item["rss_kib"] for item in runtime))
    for key in ("rust_fold_first_ms", "rust_fold_repeat_ms"):
        print(key, "median:", statistics.median(item[key] for item in folds))


if __name__ == "__main__":
    main()
