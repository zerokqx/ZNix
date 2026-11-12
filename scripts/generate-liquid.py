#!/usr/bin/env python3
"""Render a periodic GLSL scene offscreen and encode it as H.264/MP4."""

import argparse
from decimal import Decimal, InvalidOperation
import json
import math
import os
from pathlib import Path
import random
import re
import subprocess
from tempfile import TemporaryDirectory
from time import perf_counter

DEFAULT_COLORS = "#101018,#292044,#63518f,#a18ac8"
STYLIX_ROLES = ("base00", "base02", "base0E", "base0D", "base0C")
REPO = Path(__file__).resolve().parents[1]
VERTEX_SHADER = """
#version 330 core
void main() {
    vec2 point = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);
    gl_Position = vec4(point * 2.0 - 1.0, 0.0, 1.0);
}
"""


def palette(value):
    colors = [part.strip().lower() for part in value.split(",")]
    if not 2 <= len(colors) <= 6 or not all(
        re.fullmatch(r"#[0-9a-f]{6}", color) for color in colors
    ):
        raise argparse.ArgumentTypeError("expected 2–6 comma-separated #RRGGBB colors")
    return colors


def parse_args(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    palettes = parser.add_mutually_exclusive_group()
    palettes.add_argument("--colors", type=palette, help="2–6 comma-separated #RRGGBB colors")
    palettes.add_argument("--stylix", metavar="HOST", help="palette from the NixOS flake host")
    parser.add_argument("--duration", default="12", help="cycle duration in seconds (default: 12)")
    parser.add_argument("--fps", type=int, default=30)
    parser.add_argument("--width", type=int, default=1920)
    parser.add_argument("--height", type=int, default=1080)
    parser.add_argument("--speed", type=float, default=1.0, help="travel per cycle (0–4)")
    parser.add_argument("--intensity", type=float, default=1.0, help="fluid deformation (0–3)")
    parser.add_argument("--grain", type=float, default=0.12, help="film grain (0–1)")
    parser.add_argument("--softness", type=float, default=0.6, help="diffuse edges (0–1)")
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--software", action="store_true", help="force Mesa software rendering")
    parser.add_argument("--output", type=Path, default=Path("liquid-background.mp4"))
    args = parser.parse_args(argv)

    if not 1 <= args.fps <= 120:
        parser.error("--fps must be between 1 and 120")
    try:
        duration = Decimal(args.duration)
        if not duration.is_finite() or not 0 < duration <= 600:
            raise ValueError
        frames = duration * args.fps
    except (InvalidOperation, ValueError):
        parser.error("--duration must be positive and at most 600 seconds")
    if frames != int(frames) or frames < 2:
        parser.error("--duration times --fps must be a whole number of at least 2 frames")
    args.frames = int(frames)
    args.duration = float(duration)

    for key in ("width", "height"):
        value = getattr(args, key)
        if not 2 <= value <= 8192 or value % 2:
            parser.error(f"--{key} must be even and between 2 and 8192")
    for key, maximum in (("speed", 4), ("intensity", 3), ("grain", 1), ("softness", 1)):
        if not 0 <= getattr(args, key) <= maximum:
            parser.error(f"--{key} must be between 0 and {maximum}")
    if args.output.suffix.lower() != ".mp4":
        parser.error("--output must end in .mp4")
    if args.stylix is not None and not re.fullmatch(r"[A-Za-z0-9_-]+", args.stylix):
        parser.error("--stylix must name a flake host")
    return args


def stylix_palette(host):
    roles = " ".join(json.dumps(role) for role in STYLIX_ROLES)
    result = subprocess.check_output(
        [
            "nix", "eval", "--json", "--no-update-lock-file",
            f".#nixosConfigurations.{host}.config.lib.stylix.colors.withHashtag",
            "--apply", f"colors: map (role: colors.${{role}}) [ {roles} ]",
        ],
        cwd=REPO,
        text=True,
    )
    return palette(",".join(json.loads(result)))


class Renderer:
    def __init__(self, args, colors):
        import moderngl

        if args.software:
            os.environ["LIBGL_ALWAYS_SOFTWARE"] = "1"
        try:
            self.context = moderngl.create_standalone_context(require=330, backend="egl")
        except Exception as error:  # glcontext reports EGL failures as plain Exception.
            hint = "" if args.software else " Try --software if hardware EGL is unavailable."
            raise RuntimeError(f"cannot create a headless OpenGL context: {error}.{hint}") from error
        program = self.context.program(
            vertex_shader=VERTEX_SHADER,
            fragment_shader=Path(__file__).with_name("liquid.frag").read_text(),
        )
        self.orbit = program["orbit"]
        self.vertex_array = self.context.vertex_array(program, [])
        self.framebuffer = self.context.simple_framebuffer((args.width, args.height), components=3)
        self.framebuffer.use()
        self.context.viewport = (0, 0, args.width, args.height)
        seed = random.Random(args.seed)
        program["seed_offset"].value = (seed.uniform(1, 97), seed.uniform(1, 97))
        program["resolution"].value = (args.width, args.height)
        for name in ("speed", "intensity", "grain", "softness"):
            program[name].value = getattr(args, name)
        program["color_count"].value = len(colors)
        rgb = [tuple(int(color[index:index + 2], 16) / 255 for index in (1, 3, 5)) for color in colors]
        program["palette"].value = rgb + [rgb[-1]] * (6 - len(rgb))
        self.frames = args.frames

    def frame(self, index):
        phase = math.tau * (index % self.frames) / self.frames
        self.orbit.value = (math.cos(phase), math.sin(phase))
        self.vertex_array.render(vertices=3)
        return self.framebuffer.read(components=3, alignment=1)


def encode(renderer, args):
    # Stage beside the destination so a failed render leaves existing output intact.
    with TemporaryDirectory(dir=args.output.parent) as temporary:
        staged = Path(temporary) / "liquid.mp4"
        command = [
            "ffmpeg", "-hide_banner", "-loglevel", "error",
            "-f", "rawvideo", "-pixel_format", "rgb24", "-video_size",
            f"{args.width}x{args.height}", "-framerate", str(args.fps),
            "-i", "pipe:0", "-vf", "vflip,scale=out_color_matrix=bt709:out_range=tv",
            "-an", "-c:v", "libx264", "-preset", "medium", "-crf", "16",
            "-pix_fmt", "yuv420p", "-colorspace", "bt709", "-color_primaries", "bt709",
            "-color_trc", "iec61966-2-1", "-movflags", "+faststart", str(staged),
        ]
        with subprocess.Popen(command, stdin=subprocess.PIPE) as ffmpeg:
            for index in range(args.frames):
                ffmpeg.stdin.write(renderer.frame(index))
            ffmpeg.stdin.close()
            if ffmpeg.wait():
                raise RuntimeError("FFmpeg could not encode the video")
        staged.replace(args.output)


def main():
    args = parse_args()
    try:
        colors = stylix_palette(args.stylix) if args.stylix else args.colors or palette(DEFAULT_COLORS)
        started = perf_counter()
        renderer = Renderer(args, colors)
        driver = renderer.context.info["GL_RENDERER"]
        encode(renderer, args)
    except (ImportError, OSError, ValueError, RuntimeError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"generate-liquid: {error}") from error
    finally:
        if "renderer" in locals():
            renderer.context.release()
    print(json.dumps(
        vars(args) | {
            "output": str(args.output),
            "colors": colors,
            "renderer": driver,
            "render_encode_seconds": round(perf_counter() - started, 3),
            "bytes": args.output.stat().st_size,
        },
        indent=2,
    ))


if __name__ == "__main__":
    main()
