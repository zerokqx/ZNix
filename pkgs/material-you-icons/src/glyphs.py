"""Extract flat glyphs and foreground objects from application icons."""

from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageOps


@dataclass(frozen=True)
class Glyph:
    mask: Image.Image
    method: str
    resample: Image.Resampling


class FlatGlyphExtractor:
    @staticmethod
    def _dominant_color(pixels):
        """Find the most populated RGB neighborhood, then refine its color."""
        if not len(pixels):
            raise ValueError("Could not identify a distinct tile and glyph")
        bins = pixels.astype(np.uint8) // 32
        labels = bins[:, 0].astype(int) * 64 + bins[:, 1] * 8 + bins[:, 2]
        return np.median(pixels[labels == np.bincount(labels).argmax()], axis=0)

    @staticmethod
    def _regular_tile(silhouette):
        bounds = Image.fromarray(silhouette).getbbox()
        if not bounds:
            return False
        x0, y0, x1, y1 = bounds
        actual = silhouette[y0:y1, x0:x1]
        height, width = actual.shape
        for shape in ("ellipse", "rounded"):
            expected = Image.new("1", (width, height))
            draw = ImageDraw.Draw(expected)
            box = (0, 0, width - 1, height - 1)
            if shape == "ellipse":
                draw.ellipse(box, fill=1)
            else:
                draw.rounded_rectangle(box, radius=min(width, height) * .22, fill=1)
            outline = np.asarray(expected)
            if (outline & actual).sum() / (outline | actual).sum() >= .92:
                return True
        return False

    def extract(self, image):
        image = ImageOps.contain(image, (512, 512), Image.Resampling.LANCZOS)
        rgba = np.asarray(image.convert("RGBA"), dtype=np.float32)
        rgb, alpha = rgba[:, :, :3], rgba[:, :, 3]
        corners = rgb[[0, 0, -1, -1], [0, -1, 0, -1]]
        background = np.median(corners, axis=0)
        visible = alpha > 127
        if np.all(alpha[[0, 0, -1, -1], [0, -1, 0, -1]] > 127):
            visible &= np.max(np.abs(rgb - background), axis=2) > 36
        tile = self._dominant_color(rgb[visible])
        tile_distance = np.max(np.abs(rgb - tile), axis=2)
        tile_pixels = visible & (tile_distance <= 48)

        # Filling enclosed regions keeps disjoint marks, such as Spotify's three arcs.
        enclosed = ImageOps.expand(Image.fromarray(tile_pixels.astype(np.uint8) * 255), border=1)
        ImageDraw.floodfill(enclosed, (0, 0), 127)
        silhouette = np.asarray(enclosed)[1:-1, 1:-1] != 127
        if not self._regular_tile(silhouette):
            raise ValueError("No regular flat tile found")
        interior = Image.fromarray(silhouette.astype(np.uint8) * 255)
        inset = max(3, round(min(image.size) * .018) | 1)
        interior = np.asarray(interior.filter(ImageFilter.MinFilter(inset))) == 255
        contrast = interior & (tile_distance > 58)
        if not np.any(contrast) or contrast.sum() > .55 * interior.sum():
            raise ValueError("Could not isolate a contrasting glyph inside the tile")

        glyph = self._dominant_color(rgb[contrast])
        direction = glyph - tile
        # Project mixed edge pixels onto the tile-to-glyph color axis for antialiasing.
        coverage = np.sum((rgb - tile) * direction, axis=2) / np.dot(direction, direction)
        coverage = np.clip((coverage - .15) / .85, 0, 1) * interior
        mask = Image.fromarray(np.rint(coverage * 255).astype(np.uint8))
        return Glyph(mask, "flat", Image.Resampling.LANCZOS)


class MobileSamExtractor:
    def __init__(self, checkpoint: Path, device: str = "auto"):
        self.checkpoint = checkpoint
        self.device = device
        self._generator = None

    def _load(self):
        if self._generator is None:
            import torch
            from mobile_sam import SamAutomaticMaskGenerator, sam_model_registry

            device = self.device
            if device == "auto":
                device = "cuda" if torch.cuda.is_available() else "cpu"
            if device == "cuda" and not torch.cuda.is_available():
                raise RuntimeError("A GPU was requested, but PyTorch cannot access it")
            model = sam_model_registry["vit_t"](checkpoint=str(self.checkpoint)).to(device).eval()
            backend = f"{torch.cuda.get_device_name()} ({'ROCm' if torch.version.hip else 'CUDA'})" if device == "cuda" else "CPU"
            print(f"MobileSAM device: {backend}", flush=True)
            self._generator = SamAutomaticMaskGenerator(
                model, points_per_side=8, points_per_batch=16, pred_iou_thresh=.75,
                stability_score_thresh=.83, box_nms_thresh=.85,
            )
        return self._generator

    def extract(self, image):
        image = ImageOps.contain(image, (512, 512), Image.Resampling.NEAREST)
        canvas = Image.alpha_composite(Image.new("RGBA", image.size, "#040509"), image)
        mask = self._three_tones(canvas, self._segment(canvas))
        return Glyph(mask, "MobileSAM", Image.Resampling.NEAREST)

    @staticmethod
    def _foreground_pixels(rgb):
        border = np.concatenate((rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]))
        background = np.median(border, axis=0)
        return (np.abs(rgb - background).max(axis=2) > 30)

    @staticmethod
    def _dominant_mask(proposals, foreground):
        def rank(proposal):
            mask = proposal["segmentation"]
            area = proposal["area"]
            if not .025 * mask.size <= area <= .80 * mask.size:
                return 0
            visible = np.count_nonzero(mask & foreground) / area
            ys, xs = np.nonzero(mask)
            center = 1 - np.hypot(ys.mean() / mask.shape[0] - .5, xs.mean() / mask.shape[1] - .5)
            return area * visible**2 * center * proposal["predicted_iou"] * proposal["stability_score"]

        best = max(proposals, key=rank, default=None)
        if best is None or rank(best) == 0:
            raise ValueError("MobileSAM did not find a prominent foreground object")
        return best["segmentation"]

    @staticmethod
    def _narrower_part(visible):
        """Find a dominant upper part separated by a pronounced narrowing."""
        first, last = np.flatnonzero(visible.any(axis=1))[[0, -1]]
        rows = visible[first:last + 1]
        widths = rows.shape[1] - rows.argmax(axis=1) - rows[:, ::-1].argmax(axis=1)
        widths = np.where(rows.any(axis=1), widths, 0)
        widths = np.convolve(widths, np.ones(7) / 7, mode="same")
        cumulative = np.cumsum(rows.sum(axis=1)) / rows.sum()
        for i in np.argsort(widths):
            if not .50 <= i / len(rows) <= .85 or not .65 <= cumulative[i] <= .92:
                continue
            if widths[i] < .55 * min(widths[:i].max(), widths[i:].max()):
                return first + int(i)
        return None

    def _segment(self, image):
        rgb = np.asarray(image.convert("RGB"))
        foreground = self._foreground_pixels(rgb)
        if not foreground.any():
            raise ValueError("No visible foreground to segment")

        import torch
        generator = self._load()
        mask = self._dominant_mask(generator.generate(rgb), foreground)
        visible = mask & foreground
        cut = self._narrower_part(visible)
        if cut is not None:
            ys, xs = np.nonzero(visible[:cut])
            lower_y, lower_x = np.nonzero(visible[cut + 1:])
            predictor = generator.predictor
            with torch.inference_mode():
                predictor.set_image(rgb)
                masks, scores, _ = predictor.predict(
                    point_coords=np.array([[np.median(xs), np.percentile(ys, 34)],
                                           [np.median(lower_x), np.median(lower_y) + cut + 1]]),
                    point_labels=np.array([1, 0]),
                    box=np.array([xs.min(), ys.min(), xs.max(), cut]),
                )
            area = mask.sum()
            for index in np.argsort(scores)[::-1]:
                candidate = masks[index]
                candidate_area = candidate.sum()
                if .55 * area <= candidate_area <= .92 * area and candidate[cut + 4:].sum() < .05 * candidate_area:
                    return candidate
        return mask

    def _three_tones(self, image, mask):
        grayscale = np.asarray(image.convert("L"), dtype=np.float32)
        visible = mask & self._foreground_pixels(np.asarray(image.convert("RGB")))
        outline = ImageOps.expand(Image.fromarray(visible.astype(np.uint8) * 255), border=1)
        ImageDraw.floodfill(outline, (0, 0), 127)
        trimmed = np.asarray(outline)[1:-1, 1:-1] != 127
        if trimmed.sum() >= .70 * mask.sum():
            mask = trimmed
        dark, bright = np.percentile(grayscale[mask], (7, 92))
        value = np.clip((grayscale - dark) / max(bright - dark, 12), 0, 1)
        midtones = np.clip((value - .15) / .14, 0, 1)
        highlights = np.clip((value - .65) / .16, 0, 1)
        tones = .12 + .73 * midtones + .15 * highlights

        return Image.fromarray(np.rint(255 * tones * mask).astype(np.uint8))
