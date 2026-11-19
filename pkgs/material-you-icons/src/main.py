"""Command-line interface for Material You icon rendering."""

import argparse
import sys
from pathlib import Path

if __package__:
    from .rendering import IconRenderer, WEIGHTS
    from .system_icons import SystemIconSource
    from .theme import ThemeInstaller
else:
    from rendering import IconRenderer, WEIGHTS
    from system_icons import SystemIconSource
    from theme import ThemeInstaller


class IconCLI:
    def __init__(self):
        self.parser = argparse.ArgumentParser(prog="render-icon", description=__doc__)
        common = argparse.ArgumentParser(add_help=False)
        common.add_argument("--device", choices=("auto", "cpu", "cuda"), default="auto")
        common.add_argument("--checkpoint", type=Path, default=WEIGHTS, help="MobileSAM weights")
        common.add_argument("--palette", type=Path, help="JSON with background, container and glyph colors")

        commands = self.parser.add_subparsers(dest="command", required=True)
        single = commands.add_parser("render", parents=[common], help="Render one icon")
        single.add_argument("input", type=Path)
        single.add_argument("output", type=Path)
        single.add_argument("--mask", type=Path, help="Save the extracted glyph mask")

        folder = commands.add_parser("batch", parents=[common], help="Render all PNG files in a directory")
        folder.add_argument("--input-dir", type=Path, required=True)
        system = commands.add_parser("system", parents=[common], help="Render installed application icons")
        for command in (folder, system):
            command.add_argument("--output-dir", type=Path, required=True)
            command.add_argument("--mask-dir", type=Path, help="Save extracted glyph masks here")
        install = commands.add_parser("install", parents=[common], help="Install a user icon theme from installed apps")
        install.add_argument("--theme-dir", type=Path, required=True)
        install.add_argument("--inherits", default="hicolor", help="Parent theme for missing icons")

    def run(self):
        args = self.parser.parse_args()
        try:
            renderer = IconRenderer(palette=args.palette, checkpoint=args.checkpoint, device=args.device)
            source = SystemIconSource()
            if args.command == "render":
                self._render(renderer, source, args.input, args.output, args.mask)
                return 0
            if args.command == "install":
                installed, skipped = ThemeInstaller(renderer, source).install(args.theme_dir, args.inherits)
                print(f"Installed {installed} named icons, skipped {skipped}.", flush=True)
                return 0
            return self._render_many(args, renderer, source)
        except (ImportError, KeyError, OSError, RuntimeError, ValueError) as error:
            self.parser.exit(1, f"{self.parser.prog}: {error}\n")

    @staticmethod
    def _render(renderer, source, path, output, mask):
        source_path = path.resolve()
        output_path = output.resolve()
        if output_path == source_path or (mask is not None and mask.resolve() in (source_path, output_path)):
            raise ValueError("Input, output and mask must use distinct paths")
        method = renderer.render(source.open(path), output, mask)
        print(f"{method}: {output}", flush=True)

    def _render_many(self, args, renderer, source):
        output = args.output_dir.resolve()
        masks = args.mask_dir.resolve() if args.mask_dir else None
        if masks == output:
            raise ValueError("--output-dir and --mask-dir must differ")
        if args.command == "batch":
            input_dir = args.input_dir.resolve()
            if input_dir in (output, masks):
                raise ValueError("Input, output and mask directories must differ")
            icons = [
                (path.stem, path) for path in sorted(input_dir.iterdir())
                if path.is_file() and path.suffix.lower() == ".png"
            ]
            if len({name for name, _ in icons}) != len(icons):
                raise ValueError("PNG filenames must be unique apart from their extensions")
        else:
            icons = source.iter_icons()

        rendered = skipped = 0
        for name, path in icons:
            mask = masks / f"{name}.png" if masks else None
            try:
                self._render(renderer, source, path, output / f"{name}.png", mask)
                rendered += 1
            except (OSError, ValueError) as error:
                print(f"Skipped {name}: {error}", file=sys.stderr)
                skipped += 1
        print(f"Rendered {rendered}, skipped {skipped}.", flush=True)
        return 0 if rendered and not skipped else 1


if __name__ == "__main__":
    sys.exit(IconCLI().run())
