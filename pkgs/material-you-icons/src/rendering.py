"""Compose extracted glyphs on a fixed Material You container."""

import json
import os
from pathlib import Path

from PIL import Image, ImageOps

if __package__:
    from .glyphs import FlatGlyphExtractor, MobileSamExtractor
else:
    from glyphs import FlatGlyphExtractor, MobileSamExtractor


PROJECT = Path(__file__).resolve().parents[1]
ASSETS = PROJECT / "assets/material-you"
WEIGHTS = Path(os.environ.get("MATERIAL_YOU_ICONS_WEIGHTS") or PROJECT / "models/mobilesam/mobile_sam.pt")


class IconRenderer:
    def __init__(self, *, palette: Path | None = None, checkpoint: Path = WEIGHTS, device: str = "auto"):
        self._flat = FlatGlyphExtractor()
        self._sam = MobileSamExtractor(checkpoint, device)
        self.checkpoint = checkpoint
        colors = json.loads((palette or ASSETS / "palette.json").read_text())
        with Image.open(ASSETS / "container-mask.png") as container:
            self._size = container.size
            self._container = container.copy()
            background, self._tile, self._ink = (
                Image.new("RGB", self._size, colors[key])
                for key in ("background", "container", "glyph")
            )
            self._base = Image.composite(self._tile, background, self._container)

    def extract_mask(self, image: Image.Image) -> tuple[Image.Image, str]:
        rgba = image.convert("RGBA")
        try:
            glyph = self._flat.extract(rgba)
        except ValueError:
            glyph = self._sam.extract(rgba)

        bounds = glyph.mask.getbbox()
        if bounds is None:
            raise ValueError("Could not recover the glyph")
        extent = round(min(self._size) * 226 / 512)
        cropped = ImageOps.contain(glyph.mask.crop(bounds), (extent, extent), glyph.resample)
        mask = Image.new("L", self._size)
        mask.paste(cropped, tuple((side - dim) // 2 for side, dim in zip(self._size, cropped.size)))
        return mask, glyph.method

    def compose(self, mask: Image.Image, *, transparent: bool = False) -> Image.Image:
        if not transparent:
            return Image.composite(self._ink, self._base, mask)
        icon = Image.composite(self._ink, self._tile, mask)
        icon.putalpha(self._container)
        return icon

    def render(self, image: Image.Image, output: Path, mask_path: Path | None = None) -> str:
        mask, method = self.extract_mask(image)
        output.parent.mkdir(parents=True, exist_ok=True)
        self.compose(mask).save(output)
        if mask_path is not None:
            mask_path.parent.mkdir(parents=True, exist_ok=True)
            mask.save(mask_path)
        return method
