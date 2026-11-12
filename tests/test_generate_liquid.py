import contextlib
import importlib.util
import io
from pathlib import Path
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "generate-liquid.py"
SPEC = importlib.util.spec_from_file_location("generate_liquid", SCRIPT)
liquid = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(liquid)


class LiquidArgumentsTest(unittest.TestCase):
    def test_supported_palette_sizes(self):
        colors = ["#000000", "#123ABC", "#234BCD", "#345CDE", "#456DEF", "#567EF0"]
        for count in range(2, 7):
            with self.subTest(count=count):
                args = liquid.parse_args(["--colors", ", ".join(colors[:count])])
                self.assertEqual(args.colors, [color.lower() for color in colors[:count]])

    def test_default_timing(self):
        args = liquid.parse_args([])
        self.assertEqual((args.width, args.height, args.frames, args.fps), (1920, 1080, 360, 30))

    def test_fractional_duration_can_describe_exact_frames(self):
        args = liquid.parse_args(["--duration", "0.5", "--fps", "6"])
        self.assertEqual(args.frames, 3)

    def test_invalid_inputs_fail_before_render(self):
        for options in (
            ["--colors", "#000,#fff"],
            ["--colors", "#123456"],
            ["--colors", ",".join(["#123456"] * 7)],
            ["--stylix", "desktop", "--colors", "#123456,#234567"],
            ["--stylix", "desktop.config"],
            ["--width", "641"],
            ["--height", "0"],
            ["--fps", "0"],
            ["--duration", "0.01"],
            ["--duration", "nan"],
            ["--speed", "inf"],
            ["--intensity", "-1"],
            ["--grain", "1.01"],
            ["--softness", "nan"],
            ["--output", "loop.webm"],
        ):
            with self.subTest(options=options), contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit) as caught:
                    liquid.parse_args(options)
                self.assertEqual(caught.exception.code, 2)
