import base64
import io
import json
from pathlib import Path
import re
import subprocess
import sys
from urllib.parse import unquote, urlsplit
import warnings


IMAGE_ENTRY = re.compile(r"\[\[ binary data .* (?:png|jpeg|gif|bmp|tiff) (\d+x\d+) \]\]")
IMAGE_FORMATS = ("PNG", "JPEG", "GIF", "BMP", "TIFF", "WEBP")
IMAGE_SUFFIXES = {".png", ".jpg", ".jpeg", ".gif", ".bmp", ".tif", ".tiff", ".webp"}
VIDEO_SUFFIXES = {".mp4", ".m4v", ".mov", ".webm", ".mkv", ".avi", ".ogv"}
MAX_IMAGE_BYTES = 16 * 1024 * 1024
MAX_TEXT = 65_536


def list_entries():
    result = subprocess.run(
        ["cliphist", "-preview-width", "360", "list"], capture_output=True,
        check=False, timeout=4,
    )
    if result.returncode and b"please store something first" not in result.stderr:
        return 1
    entries = []
    for line in result.stdout.decode("utf-8", errors="replace").split("\n"):
        identifier, separator, preview = line.partition("\t")
        if not separator or not re.fullmatch(r"[0-9]+", identifier):
            continue
        image = IMAGE_ENTRY.fullmatch(preview)
        entries.append({
            "identifier": identifier,
            "preview": image[1] if image else preview,
            "image": bool(image),
        })
    print(json.dumps(entries))
    return 0


def image_source(data, size):
    from PIL import Image

    if len(data) > MAX_IMAGE_BYTES:
        return None
    Image.MAX_IMAGE_PIXELS = 20_000_000
    output = io.BytesIO()
    with warnings.catch_warnings():
        warnings.simplefilter("error", Image.DecompressionBombWarning)
        try:
            with Image.open(io.BytesIO(data), formats=IMAGE_FORMATS) as image:
                image.thumbnail(size)
                image.convert("RGBA").save(output, format="PNG")
        except (OSError, Image.DecompressionBombError, Image.DecompressionBombWarning):
            return None
    return "data:image/png;base64," + base64.b64encode(output.getvalue()).decode("ascii")


def local_media(text):
    candidate = text.rstrip("\r\n")
    if len(candidate) > 4096 or "\r" in candidate or "\n" in candidate:
        return None
    is_uri = candidate.startswith("file://")
    if is_uri:
        parts = urlsplit(candidate)
        if parts.netloc not in ("", "localhost") or parts.query or parts.fragment:
            return None
        candidate = unquote(parts.path)
    if not candidate.startswith("/") or candidate.startswith("//") or "\0" in candidate:
        return None
    path = Path(candidate)
    suffix = path.suffix.lower()
    if suffix not in VIDEO_SUFFIXES | IMAGE_SUFFIXES:
        return None
    if not path.is_file():
        return {"kind": "unavailable"} if is_uri else None
    if suffix in VIDEO_SUFFIXES:
        return {"kind": "video", "source": path.as_uri(), "name": path.name}
    with path.open("rb") as file:
        source = image_source(file.read(MAX_IMAGE_BYTES + 1), (960, 720))
    return {"kind": "image", "source": source} if source else {"kind": "unavailable"}


def detail(data):
    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError:
        text = None
    if text is not None and not re.search(r"[\x00-\x08\x0b\x0c\x0e-\x1f]", text):
        media = local_media(text)
        if media:
            return media
        return {"kind": "text", "text": text[:MAX_TEXT], "truncated": len(text) > MAX_TEXT}
    source = image_source(data, (960, 720))
    return {"kind": "image", "source": source} if source else {"kind": "unsupported"}


def main(args):
    if args == ["list"]:
        return list_entries()
    if len(args) != 2 or args[0] not in ("copy", "preview", "detail"):
        return 2
    action, identifier = args
    if not re.fullmatch(r"[0-9]+", identifier):
        return 2
    data = subprocess.run(
        ["cliphist", "decode", identifier], stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL, check=True, timeout=4,
    ).stdout
    if action == "preview":
        source = image_source(data, (320, 200))
        if not source:
            return 1
        print(source)
        return 0
    if action == "detail":
        print(json.dumps(detail(data)))
        return 0
    return subprocess.run(
        ["wl-copy"], input=data, stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL, check=False, timeout=4,
    ).returncode


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except (OSError, ValueError, subprocess.SubprocessError):
        sys.exit(1)
