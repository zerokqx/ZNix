"""Assemble a complete DevTools frontend from the matching Chromium build."""

import gzip
import json
import re
import struct
import subprocess
import sys
from pathlib import Path, PurePosixPath

import brotli
from elftools.elf.elffile import ELFFile


def resource_paths(binary):
    # Chromium's generated GRIT map is an array of webui::ResourcePath. On
    # Linux x86_64 each 32-byte record holds the relocated path pointer and a u32 ID.
    symbols = subprocess.check_output(["nm", "-S", binary], text=True)
    tables = [
        (int(address, 16), int(size, 16))
        for line in symbols.splitlines()
        if line.endswith(" kDevtoolsResources")
        for address, size, _, _ in [line.split()]
    ]
    if len(tables) != 1:
        raise ValueError("Expected kDevtoolsResources in the unstripped Chromium binary")
    [(base, size)] = tables
    records = range(base, base + size, 32)

    with binary.open("rb") as stream:
        elf = ELFFile(stream)
        if (
            elf["e_machine"] != "EM_X86_64"
            or elf.elfclass != 64
            or not elf.little_endian
            or not size
            or size % 32
        ):
            raise ValueError("Expected Chromium's Linux x86_64 webui::ResourcePath layout")

        table = next(elf.address_offsets(base, size), None)
        if table is None:
            raise ValueError("Chromium's DevTools resource map lies outside the file")
        stream.seek(table)
        ids = [record[0] for record in struct.iter_unpack("<8xI20x", stream.read(size))]

        # Read ELF64 Rela records directly. The PIE keeps each string address
        # in the addend of an R_X86_64_RELATIVE relocation.
        rela = elf.get_section_by_name(".rela.dyn")
        if rela is None:
            raise ValueError("Chromium has no .rela.dyn section for DevTools resource paths")
        pointers = {
            offset: addend
            for offset, kind, addend in struct.iter_unpack("<QQq", rela.data())
            if kind == 8 and offset in records
        }
        if len(pointers) != len(records):
            raise ValueError("Missing R_X86_64_RELATIVE relocations in the DevTools resource map")
        for record, resource_id in zip(records, ids, strict=True):
            [offset] = elf.address_offsets(pointers[record])
            stream.seek(offset)
            raw_name, terminator, _ = stream.read(1024).partition(b"\0")
            name = raw_name.decode("ascii")
            path = PurePosixPath(name)
            if not terminator or not path.parts or path.is_absolute() or ".." in path.parts:
                raise ValueError(f"Invalid DevTools resource path: {name}")
            yield path, resource_id


def unpack_frontend(binary, output):
    # DataPack v5 has a 12-byte header, then resource offset pairs and alias
    # pairs. The extra offset entry marks the end of the final resource.
    pak = binary.with_name("resources.pak").read_bytes()
    if len(pak) < 12:
        raise ValueError("Truncated Chromium resources.pak header")
    version, count, alias_count = struct.unpack_from("<I4xHH", pak)
    if version != 5:
        raise ValueError(f"Unsupported Chromium DataPack version: {version}")
    alias_start = 12 + 6 * (count + 1)
    data_start = alias_start + 4 * alias_count
    if data_start > len(pak):
        raise ValueError("Truncated Chromium resources.pak index")
    entries = list(struct.iter_unpack("<HI", pak[12:alias_start]))
    locations = {rid: (start, end) for (rid, start), (_, end) in zip(entries, entries[1:])}
    for alias, index in struct.iter_unpack("<HH", pak[alias_start:data_start]):
        if index >= count:
            raise ValueError(f"Invalid Chromium DataPack resource alias: {alias}")
        locations[alias] = locations[entries[index][0]]

    for relative_path, resource_id in resource_paths(binary):
        start, end = locations.get(resource_id, (0, 0))
        if not data_start <= start <= end <= len(pak):
            raise ValueError(f"Invalid location of DevTools resource {relative_path} in resources.pak")
        data = pak[start:end]
        if data.startswith(b"\x1f\x8b"):
            data = gzip.decompress(data)
        elif data.startswith(b"\x1e\x9b"):
            data = brotli.decompress(data[8:])

        path = output / relative_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)


def apply_design(source, output, palette_css):
    tokens = output / "design_system_tokens.css"
    with tokens.open("a") as stylesheet:
        stylesheet.write("\n" + (source / "design.css").read_text())
        stylesheet.write("\n" + (source / "storage-editor.css").read_text())
        stylesheet.write("\n" + (source / "environment.css").read_text())
        if palette_css:
            stylesheet.write(
                "\n" + palette_css.read_text() + "\n" + (source / "tokens.css").read_text()
            )

    for original, override in json.loads((source / "styles.json").read_text()).items():
        original_path = PurePosixPath(original)
        css_path = output / original_path
        css = (source / override).read_text()
        if css_path.is_file():
            with css_path.open("a") as stylesheet:
                stylesheet.write("\n" + css)
            continue

        # DevTools preserves sourceURL on bundled styles, including styles
        # attached to shadow roots. Append before the original marker.
        marker = '/*# sourceURL=${import.meta.resolve("./' + original_path.name + '")} */'
        escaped = css.replace("\\", "\\\\").replace("`", "\\`").replace("${", "\\${")
        for directory in original_path.parents:
            bundle = output / directory / (directory.name + ".js")
            if bundle.is_file():
                contents = bundle.read_text()
                matches = contents.count(marker)
                if matches > 1:
                    raise ValueError(f"Multiple sourceURL markers for {original} in {bundle}")
                if matches == 1:
                    bundle.write_text(contents.replace(marker, "\n" + escaped + "\n" + marker))
                    break
        else:
            raise ValueError(f"Missing sourceURL for {original}. Review styles.json for this Chromium build.")

    for original, replacement in json.loads((source / "icons.json").read_text()).items():
        path = output / "Images" / original
        if not path.is_file():
            raise ValueError(f"Chromium no longer ships Images/{original}")
        path.write_bytes((source / "icons" / replacement).read_bytes())

    # Keep the licenses with the redistributed frontend and icons.
    (output / "LICENSE.chromium-devtools").write_bytes(
        (source / "LICENSE.chromium-devtools").read_bytes()
    )
    (output / "lucide-license.txt").write_bytes((source / "icons" / "LICENSE").read_bytes())


def install_storage_editor(source, output):
    application = output / "panels/application/application.js"
    bundle = application.read_text()
    storage_views = re.findall(r"DOMStorageItemsView:([\w$]+)\}\)", bundle)
    if len(storage_views) != 1:
        raise ValueError("Expected one DOMStorageItemsView export in the Application bundle")

    # Identify the minified class via its public export, then append the hook to
    # its constructor after setStorage(). Refuse to patch a changed layout.
    class_name = re.escape(storage_views[0])
    constructor = re.compile(
        rf"(\bclass {class_name} extends [\w$]+\{{domStorage;eventListeners;"
        r"constructor\(([\w$]+)\)\{[^{}]*?this\.setStorage\(\2\))\}"
    )
    patched, count = constructor.subn(r"\1;installZnixStorageEditor(this)}", bundle)
    if count != 1:
        raise ValueError("DOMStorageItemsView constructor changed. Review the storage editor hook.")
    application.write_text(
        'import {installStorageEditor as installZnixStorageEditor} from "../../znix/storage-editor-host.js";\n'
        + patched
    )
    runtime = output / "znix"
    runtime.mkdir(exist_ok=True)
    for name in ("storage-editor-host.js", "storage-editor.js"):
        (runtime / name).write_bytes((source / name).read_bytes())


def install_environment(source, output):
    entrypoint = output / "entrypoints/devtools_app/devtools_app.js"
    bundle = entrypoint.read_text()
    startup = 'import"../shell/shell.js";'
    if bundle.count(startup) != 1:
        raise ValueError("DevTools startup changed. Review the CSS Environment panel registration.")
    entrypoint.write_text(
        bundle.replace(startup, startup + '\nimport "../../znix/environment-meta.js";\n')
    )
    for name in ("environment-meta.js", "environment.js", "environment-overrides.js"):
        (output / "znix" / name).write_bytes((source / name).read_bytes())


if __name__ == "__main__":
    binary, output, source, *palette = map(Path, sys.argv[1:])
    unpack_frontend(binary, output)
    apply_design(source, output, palette[0] if palette else None)
    install_storage_editor(source, output)
    install_environment(source, output)
