#!/usr/bin/env python3
"""Structural checks for ForeverKit (no WoW client required)."""

from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
ADDON = ROOT / "ForeverKit"
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


def check_toc(toc: pathlib.Path) -> list[str]:
    errors = []
    text = toc.read_text(encoding="utf-8")
    if "## Interface:" not in text:
        errors.append(f"{toc.name}: missing Interface")
    files = parse_toc(toc)
    if not files:
        errors.append(f"{toc.name}: no files listed")
    for rel in files:
        path = ADDON / rel
        if not path.is_file():
            errors.append(f"{toc.name}: missing {rel}")
    return errors


def check_lua(path: pathlib.Path) -> list[str]:
    errors = []
    text = path.read_text(encoding="utf-8")
    if "function" in text:
        # Crude balance: function vs end is too noisy because of if/end.
        pass
    for regex, message in FORBIDDEN:
        if regex.search(text):
            errors.append(f"{path.relative_to(ROOT)}: {message}")
    opens = text.count("function")
    # Count only statement-level end is hard; check for unmatched [[
    if text.count("[[") != text.count("]]"):
        errors.append(f"{path.relative_to(ROOT)}: unmatched long brackets")
    if opens == 0 and path.name.endswith(".lua") and path.name != "Locale.lua":
        # Locale has no functions besides setmetatable callback... it has none named function except none
        pass
    return errors


def main() -> int:
    errors: list[str] = []
    tocs = list(ADDON.glob("*.toc"))
    if not tocs:
        errors.append("no toc files")
    for toc in tocs:
        errors.extend(check_toc(toc))

    expected = {"ForeverKit.toc", "ForeverKit_Camelot.toc", "ForeverKit_Mainline.toc"}
    found = {p.name for p in tocs}
    missing = expected - found
    if missing:
        errors.append(f"missing toc variants: {sorted(missing)}")

    for lua in ADDON.rglob("*.lua"):
        errors.extend(check_lua(lua))

    if errors:
        print("FAIL")
        for err in errors:
            print(" -", err)
        return 1
    print(f"OK: {len(tocs)} toc, {len(list(ADDON.rglob('*.lua')))} lua files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
