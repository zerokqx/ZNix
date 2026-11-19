"""Discover installed desktop application icons."""

import configparser
import os
import shutil
import subprocess
from io import BytesIO
from pathlib import Path

from PIL import Image


VECTOR_FORMATS = {".svg", ".svgz"}
ICON_FORMATS = VECTOR_FORMATS | {".png", ".xpm", ".ico"}
ICON_SIZE = (512, 512)


class SystemIconSource:
    """Find installed application icons and load them as detached RGBA images."""

    def __init__(self):
        self.home = Path.home()

    def iter_icons(self):
        """Yield each visible desktop entry ID and its resolved icon path."""
        for desktop_id, _, source in self._resolved_icons():
            yield desktop_id, source

    def iter_theme_icons(self, theme, inherits):
        """Yield named icons that can be replaced through XDG theme lookup."""
        seen = set()
        for _, name, source in self._resolved_icons(theme, inherits):
            if name and name not in seen and "/" not in name and name not in (".", ".."):
                seen.add(name)
                yield name, source

    def _resolved_icons(self, excluded_theme=None, fallback_theme=None):
        roots = self._data_dirs()
        launchers = list(self._launchers(roots))
        package_roots = [path.resolve().parents[1] for _, _, path in launchers]
        names = {
            self._icon_name(icon) for _, icon, _ in launchers if not Path(icon).expanduser().is_absolute()
        }
        icons = self._icon_index(
            list(dict.fromkeys([*roots, *package_roots])), names, excluded_theme, fallback_theme
        )
        for desktop_id, icon, _ in launchers:
            source = Path(icon).expanduser()
            name = None
            if not source.is_absolute():
                name = self._icon_name(icon)
                source = icons.get(name)
            if source is not None and source.is_file():
                yield desktop_id, name, source

    @staticmethod
    def _icon_name(icon):
        path = Path(icon)
        return path.stem if path.suffix.lower() in ICON_FORMATS else icon

    @staticmethod
    def open(source_path):
        """Load an icon as a detached RGBA PIL image."""
        source = Path(source_path)
        if source.suffix.lower() in VECTOR_FORMATS:
            converter = shutil.which("rsvg-convert")
            if converter is None:
                raise OSError(f"Cannot open SVG icon {source}. Run inside the project's devenv shell for librsvg.")
            try:
                png = subprocess.run(
                    [converter, "--width", str(ICON_SIZE[0]), "--height", str(ICON_SIZE[1]),
                     "--keep-aspect-ratio", str(source)],
                    check=True, capture_output=True,
                ).stdout
            except (OSError, subprocess.CalledProcessError) as error:
                detail = error.stderr.decode(errors="replace").strip() if getattr(error, "stderr", None) else str(error)
                raise OSError(f"Could not render SVG icon {source}: {detail}") from error
            image_source = BytesIO(png)
        else:
            image_source = source
        try:
            with Image.open(image_source) as image:
                return image.convert("RGBA")
        except (OSError, ValueError) as error:
            raise OSError(f"Could not open icon {source}: {error}") from error

    def _data_dirs(self):
        state = Path(os.environ.get("XDG_STATE_HOME") or self.home / ".local/state")
        roots = [
            Path(os.environ.get("XDG_DATA_HOME") or self.home / ".local/share"),
            *(Path(path) for path in os.environ.get("XDG_DATA_DIRS", "").split(":") if path),
            self.home / ".local/share/flatpak/exports/share",
            Path("/var/lib/flatpak/exports/share"),
            self.home / ".nix-profile/share",
            state / "nix/profile/share",
            Path("/etc/profiles/per-user") / self.home.name / "share",
            Path("/run/current-system/sw/share"),
            Path("/usr/local/share"),
            Path("/usr/share"),
        ]
        return list(dict.fromkeys(root for root in roots if root.is_dir()))

    @staticmethod
    def _launchers(roots):
        seen = set()
        for root in roots:
            applications = root / "applications"
            for path in sorted(applications.rglob("*.desktop")):
                desktop_id = "-".join(path.relative_to(applications).parts)
                if desktop_id in seen:
                    continue
                seen.add(desktop_id)
                entry = configparser.ConfigParser(interpolation=None, strict=False)
                try:
                    entry.read(path, encoding="utf-8")
                    app = entry["Desktop Entry"]
                except (configparser.Error, KeyError, UnicodeError):
                    continue
                if app.get("Type") != "Application" or any(
                    app.get(flag, "").lower() == "true" for flag in ("Hidden", "NoDisplay")
                ):
                    continue
                if icon := app.get("Icon"):
                    yield desktop_id.removesuffix(".desktop"), icon, path

    def _icon_index(self, roots, names, excluded_theme, fallback_theme):
        index = {}
        for directory in [self.home / ".icons", *(root / "icons" for root in roots)]:
            for path in directory.glob("*/*/*/*"):
                suffix = path.suffix.lower()
                theme = path.parents[2].name
                if theme == excluded_theme or path.stem not in names or suffix not in ICON_FORMATS or not path.is_file():
                    continue
                size = path.parent.parent.name.removesuffix("@2").split("x")[0]
                resolution = ICON_SIZE[0] if suffix in VECTOR_FORMATS else int(size) if size.isdecimal() else 0
                priority = 2 if theme == "hicolor" else int(theme == fallback_theme)
                rank = (priority, min(resolution, ICON_SIZE[0]))
                if path.stem not in index or rank > index[path.stem][0]:
                    index[path.stem] = (rank, path)

        fallback_dirs = [
            self.home / ".icons",
            *(root / "pixmaps" for root in roots),
            *(root / "icons" for root in roots),
        ]
        for directory in fallback_dirs:
            for path in sorted(directory.iterdir()) if directory.is_dir() else ():
                if path.stem in names and path.suffix.lower() in ICON_FORMATS and path.is_file():
                    index.setdefault(path.stem, ((False, 0), path))
        return {name: path for name, (_, path) in index.items()}
