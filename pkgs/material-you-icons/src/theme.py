"""Generate and install a user-owned freedesktop icon theme."""

import fcntl
import hashlib
import json
import os
from pathlib import Path
from tempfile import TemporaryDirectory

from PIL import Image


class ThemeInstaller:
    icon_directory = "512x512/apps"

    def __init__(self, renderer, source):
        self.renderer = renderer
        self.source = source
        self.cache = Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache") / "material-you-icons/masks"
        checkpoint = renderer.checkpoint
        signature = hashlib.sha256()
        for name in ("glyphs.py", "rendering.py"):
            signature.update(Path(__file__).with_name(name).read_bytes())
        if checkpoint.is_file():
            with checkpoint.open("rb") as weights:
                signature.update(hashlib.file_digest(weights, "sha256").digest())
        self._signature = signature.digest()

    def _mask(self, image):
        digest = hashlib.sha256(self._signature + str(image.size).encode() + image.tobytes()).hexdigest()
        path = self.cache / f"{digest}.png"
        try:
            with Image.open(path) as saved:
                if saved.mode == "L" and saved.size == (512, 512):
                    return saved.copy(), "cached"
        except OSError:
            pass
        mask, method = self.renderer.extract_mask(image)
        self.cache.mkdir(parents=True, exist_ok=True)
        with TemporaryDirectory(dir=self.cache) as temp:
            generated = Path(temp) / "mask.png"
            mask.save(generated)
            generated.replace(path)
        return mask, method

    def install(self, theme_dir, inherits):
        if theme_dir.name == inherits or not inherits or any(c in inherits for c in "/,\r\n"):
            raise ValueError("Choose a different parent icon theme")
        if theme_dir.is_symlink():
            raise ValueError(f"Cannot manage a symlinked theme directory: {theme_dir}")
        theme_dir.mkdir(parents=True, exist_ok=True)
        marker = theme_dir / ".material-you-icons.lock"
        if marker.is_symlink() or (not marker.is_file() and any(theme_dir.iterdir())):
            raise ValueError(f"Refusing to replace an existing icon theme: {theme_dir}")
        registry = theme_dir / ".material-you-icons.json"
        with marker.open("a") as state:
            fcntl.flock(state, fcntl.LOCK_EX)
            previous = json.loads(registry.read_text()) if registry.is_file() else []
            return self._install(theme_dir, inherits, registry, previous)

    def _install(self, theme_dir, inherits, registry, previous):
        icons = theme_dir / self.icon_directory
        if icons.is_symlink() or icons.parent.is_symlink():
            raise ValueError(f"Cannot manage a symlinked icon directory: {icons}")
        icons.mkdir(parents=True, exist_ok=True)
        rendered = []
        skipped = 0
        with TemporaryDirectory(dir=theme_dir, prefix=".render-") as temp:
            stage = Path(temp)
            for name, original in self.source.iter_theme_icons(theme_dir.name, inherits):
                filename = f"{name}.png"
                try:
                    image = self.source.open(original)
                    mask, method = self._mask(image)
                    self.renderer.compose(mask, transparent=True).save(stage / filename)
                except (OSError, ValueError) as error:
                    print(f"Skipped {name}: {error}", flush=True)
                    skipped += 1
                    continue
                rendered.append(filename)
                print(f"{method}: {name}", flush=True)

            parents = "hicolor" if inherits == "hicolor" else f"{inherits},hicolor"
            index = (
                f"[Icon Theme]\nName={theme_dir.name}\nComment=Material You application icons\n"
                f"Inherits={parents}\nDirectories={self.icon_directory}\n\n"
                f"[{self.icon_directory}]\nSize=512\nType=Fixed\nContext=Applications\n"
            )
            (stage / "index.theme").write_text(index)
            (stage / registry.name).write_text(json.dumps(rendered) + "\n")
            for name in rendered:
                (stage / name).replace(icons / name)
            for stale in set(previous) - set(rendered):
                if Path(stale).name == stale and stale.endswith(".png"):
                    (icons / stale).unlink(missing_ok=True)
            (stage / "index.theme").replace(theme_dir / "index.theme")
            (stage / registry.name).replace(registry)
            os.utime(theme_dir, None)
        return len(rendered), skipped
