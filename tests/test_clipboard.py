import contextlib
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import unittest
from unittest.mock import patch


PATH = Path(__file__).resolve().parents[1] / "home/zerokqx/clipboard/history.py"
SPEC = importlib.util.spec_from_file_location("clipboard_history", PATH)
history = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(history)


class ClipboardHistoryTests(unittest.TestCase):
    def test_list_accepts_image_formats_and_preserves_plain_text(self):
        formats = ("png", "jpeg", "gif", "bmp", "tiff")
        lines = [
            f"{index}\t[[ binary data 12 KiB {kind} 320x200 ]]"
            for index, kind in enumerate(formats, start=1)
        ]
        lines += ["6\t<b>тест</b> $(echo hello)", "invalid\tignored"]
        result = subprocess.CompletedProcess([], 0, "\n".join(lines).encode(), b"")
        output = io.StringIO()
        with patch.object(history.subprocess, "run", return_value=result), contextlib.redirect_stdout(output):
            self.assertEqual(history.main(["list"]), 0)
        entries = json.loads(output.getvalue())
        self.assertEqual(len(entries), 6)
        self.assertTrue(all(entry["image"] and entry["preview"] == "320x200" for entry in entries[:5]))
        self.assertEqual(entries[5], {"identifier": "6", "preview": "<b>тест</b> $(echo hello)", "image": False})

    def test_copy_keeps_original_multiline_and_binary_bytes(self):
        original = b"first line\nsecond line\x00\xff"
        decoded = subprocess.CompletedProcess([], 0, original)
        copied = subprocess.CompletedProcess([], 0)
        with patch.object(history.subprocess, "run", side_effect=(decoded, copied)) as run:
            self.assertEqual(history.main(["copy", "42"]), 0)
        self.assertEqual(run.call_args_list[0].args[0], ["cliphist", "decode", "42"])
        self.assertEqual(run.call_args_list[1].args[0], ["wl-copy"])
        self.assertEqual(run.call_args_list[1].kwargs["input"], original)

    def test_rejects_invalid_id_before_running_any_command(self):
        with patch.object(history.subprocess, "run") as run:
            self.assertEqual(history.main(["preview", "42; echo hello"]), 2)
        run.assert_not_called()
