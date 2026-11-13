import contextlib
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import tempfile
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
            for action in ("preview", "detail"):
                self.assertEqual(history.main([action, "42; echo hello"]), 2)
        run.assert_not_called()

    def test_detail_keeps_multiline_text_and_limits_oversized_preview(self):
        text = "Первая строка\n<b>обычный текст</b>\n" + "X" * history.MAX_TEXT
        result = history.detail(text.encode())
        self.assertEqual(result, {"kind": "text", "text": text[:history.MAX_TEXT], "truncated": True})

    def test_detail_only_opens_single_local_media_path_or_uri(self):
        with tempfile.TemporaryDirectory() as directory:
            video = Path(directory) / "local clip.mp4"
            video.touch()
            uri = video.as_uri()
            for text in (uri + "\r\n", str(video)):
                self.assertEqual(
                    history.detail(text.encode()),
                    {"kind": "video", "source": uri, "name": video.name},
                )
            for text in (video.name, uri + "\n" + uri, "https://example.org/clip.mp4", "file://example.org/clip.mp4"):
                with self.subTest(text=text):
                    self.assertEqual(history.detail(text.encode()), {"kind": "text", "text": text, "truncated": False})
            video.unlink()
            self.assertEqual(history.detail(uri.encode()), {"kind": "unavailable"})
            self.assertEqual(history.detail(str(video).encode()), {"kind": "text", "text": str(video), "truncated": False})

    def test_detail_never_displays_unsupported_binary_as_text(self):
        with patch.object(history, "image_source", return_value=None):
            self.assertEqual(history.detail(b"\x00\xff\x80"), {"kind": "unsupported"})
