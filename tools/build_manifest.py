#!/usr/bin/env python3
"""Create a deterministic source manifest for release tooling.

This deliberately does not claim to provide security through obfuscation. The manifest
can be consumed by a private release pipeline to minify/sign artifacts server-side.
"""
from __future__ import annotations
import hashlib, json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
OUT = ROOT / "build" / "manifest.json"

files = []
for file in sorted(SRC.rglob("*.lua")):
    data = file.read_bytes()
    files.append({
        "path": file.relative_to(ROOT).as_posix(),
        "bytes": len(data),
        "sha256": hashlib.sha256(data).hexdigest(),
    })
OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(json.dumps({"schema": 1, "files": files}, indent=2) + "\n", encoding="utf-8")
print(f"Wrote {OUT.relative_to(ROOT)} ({len(files)} files)")
