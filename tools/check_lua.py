#!/usr/bin/env python3
"""Structural checks for Forever addons (no WoW client required)."""

from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
ADDONS = [ROOT / "ForeverKit", ROOT / "LumiereUI"]
FORBIDDEN = [
    (re.compile(r"\bUnitAura\s*\("), "UnitAura is secret-restricted; use AuraContainer / spell-id APIs"),
    (re.compile(r"\bUnitHealth\s*\("), "UnitHealth can be secret in combat; avoid combat logic"),
    (re.compile(r"\bSetRaidTarget\s*\("), "Automated raid marks are disallowed"),
]


def parse_toc(toc: pathlib.Path) -> list[str]:
    files = []
    for raw in toc.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        files.append(line.split()[0].replace("\\", "/"))
    return files


def check_toc(addon: pathlib.Path, toc: pathlib.Path) -> list[str]:
    errors = []
    text = toc.read_text(encoding="utf-8")
    if "## Interface:" not in text:
        errors.append(f"{addon.name}/{toc.name}: missing Interface")
    files = parse_toc(toc)
    if not files:
        errors.append(f"{addon.name}/{toc.name}: no files listed")
    for rel in files:
        path = addon / rel
        if not path.is_file():
            errors.append(f"{addon.name}/{toc.name}: missing {rel}")
    return errors


def check_lua(path: pathlib.Path) -> list[str]:
    errors = []
    text = path.read_text(encoding="utf-8")
    for regex, message in FORBIDDEN:
        if regex.search(text):
            errors.append(f"{path.relative_to(ROOT)}: {message}")
    return errors


def main() -> int:
    errors: list[str] = []
    lua_count = 0
    toc_count = 0
    for addon in ADDONS:
        if not addon.is_dir():
            errors.append(f"missing addon folder {addon.name}")
            continue
        tocs = list(addon.glob("*.toc"))
        toc_count += len(tocs)
        if not tocs:
            errors.append(f"{addon.name}: no toc files")
        stem = addon.name
        expected = {f"{stem}.toc", f"{stem}_Camelot.toc", f"{stem}_Mainline.toc"}
        found = {p.name for p in tocs}
        missing = expected - found
        if missing:
            errors.append(f"{addon.name}: missing toc variants: {sorted(missing)}")
        for toc in tocs:
            errors.extend(check_toc(addon, toc))
        for lua in addon.rglob("*.lua"):
            lua_count += 1
            errors.extend(check_lua(lua))

    if errors:
        print("FAIL")
        for err in errors:
            print(" -", err)
        return 1
    print(f"OK: {toc_count} toc, {lua_count} lua files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
