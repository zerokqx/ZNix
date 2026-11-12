import base64
import io
import json
import re
import subprocess
import sys
import warnings


IMAGE_ENTRY = re.compile(r"\[\[ binary data .* (?:png|jpeg|gif|bmp|tiff) (\d+x\d+) \]\]")


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


def thumbnail(data):
    from PIL import Image

    if len(data) > 16 * 1024 * 1024:
        return 1
    Image.MAX_IMAGE_PIXELS = 20_000_000
    output = io.BytesIO()
    with warnings.catch_warnings():
        warnings.simplefilter("error", Image.DecompressionBombWarning)
        try:
            with Image.open(io.BytesIO(data), formats=("PNG", "JPEG", "GIF", "BMP", "TIFF")) as image:
                image.thumbnail((320, 200))
                image.convert("RGBA").save(output, format="PNG")
        except (Image.DecompressionBombError, Image.DecompressionBombWarning):
            return 1
    print("data:image/png;base64," + base64.b64encode(output.getvalue()).decode("ascii"))
    return 0


def main(args):
    if args == ["list"]:
        return list_entries()
    if len(args) != 2 or args[0] not in ("copy", "preview"):
        return 2
    action, identifier = args
    if not re.fullmatch(r"[0-9]+", identifier):
        return 2
    data = subprocess.run(
        ["cliphist", "decode", identifier], stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL, check=True, timeout=4,
    ).stdout
    if action == "preview":
        return thumbnail(data)
    return subprocess.run(
        ["wl-copy"], input=data, stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL, check=False, timeout=4,
    ).returncode


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except (OSError, ValueError, subprocess.SubprocessError):
        sys.exit(1)
