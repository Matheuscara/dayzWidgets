#!/usr/bin/env python3
"""Verifica manifests, arquivos de licença, links de entrada e conteúdo privado."""
import ast
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
entries = json.loads((ROOT / "plugins.json").read_text())["plugins"]
ids = set()
for item in entries:
    folder = ROOT / "plugins" / item["directory"]
    manifest = json.loads((folder / "plugin.json").read_text())
    assert manifest["id"] not in ids, "ID duplicado"
    ids.add(manifest["id"])
    assert manifest["id"] == item["id"]
    assert (folder / "LICENSE").is_file(), folder
    for field in ["component", "settings"]:
        if field in manifest:
            path = (folder / manifest[field]).resolve()
            assert path.is_relative_to(folder.resolve()) and path.is_file(), path
    if item["kind"] == "adaptation":
        assert (folder / "NOTICE.md").is_file()
        assert len(item["upstream"]["revision"]) == 40
for path in ROOT.rglob("*"):
    if ".git" in path.parts or "__pycache__" in path.parts or not path.is_file():
        continue
    if path.suffix == ".py":
        ast.parse(path.read_text())
    if path.suffix in {".qml", ".json", ".py", ".nix", ".md", ".txt", ".yml"}:
        text = path.read_text()
        forbidden = [r"/home/" + "matheus/", r"gh" + r"[opusr]_[A-Za-z0-9]{20,}", r"-----BEGIN " + r"(?:OPENSSH|RSA|EC) PRIVATE KEY-----"]
        for pattern in forbidden:
            assert not re.search(pattern, text), f"Conteúdo privado em {path.relative_to(ROOT)}"
print(f"{len(entries)} plugins: manifests, licenças, entradas e conteúdo conferidos")
