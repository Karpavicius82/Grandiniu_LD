#!/usr/bin/env python3
"""Check that the downloadable ZIP includes the complete tested student runtime."""
import hashlib
import json
from pathlib import Path
import zipfile

root = Path(__file__).resolve().parents[1]
student = root / "studentui"
manifest = json.loads((student / "tests/results/PATIKRA.json").read_text())
prefix = "Grandiniu_LD-studentui/"

with zipfile.ZipFile(root / "dist/Grandiniu_LD-studentui.zip") as archive:
    assert archive.testzip() is None, "Corrupt ZIP entry"
    runtime = {str(path.relative_to(student)) for path in student.rglob("*")
               if path.is_file() and path.suffix in {".sci", ".sce", ".sh"}}
    assert runtime == set(manifest["source_sha256"]), "Runtime and test manifest differ"
    for name in sorted(runtime):
        local = (student / name).read_bytes()
        assert hashlib.sha256(local).hexdigest() == manifest["source_sha256"][name], name
        assert archive.read(prefix + name) == local, f"Missing or outdated ZIP source: {name}"
    for name in ["README.md", "LD1/VARIANTAI.csv", "LD2/VARIANTAI.csv", "LD3/VARIANTAI.csv", "capture_window.py"]:
        assert archive.read(prefix + name) == (student / name).read_bytes(), name
    for name in ["PALEISTI.sh", "PATIKRINTI.sh"]:
        assert (archive.getinfo(prefix + name).external_attr >> 16) & 0o111, name

print(f"PASS: ZIP contains all {len(runtime)} tested runtime files with matching SHA256 and executable launchers")
