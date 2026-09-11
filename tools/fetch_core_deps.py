#!/usr/bin/env python3
"""Developer/CI dependency setup; students need only the prebuilt binaries."""
import hashlib
import io
from pathlib import Path
import sys
import tarfile
import urllib.request

root = Path(sys.argv[1]).resolve()
root.mkdir(parents=True, exist_ok=True)
deps = [
    ("eigen-5.0.0.tar.gz", "https://gitlab.com/libeigen/eigen/-/archive/5.0.0/eigen-5.0.0.tar.gz", "315c881e19e17542a7d428c5aa37d113c89b9500d350c433797b730cd449c056"),
    ("json.hpp", "https://raw.githubusercontent.com/nlohmann/json/v3.12.0/single_include/nlohmann/json.hpp", "aaf127c04cb31c406e5b04a63f1ae89369fccde6d8fa7cdda1ed4f32dfc5de63"),
]
for name, url, digest in deps:
    path = root / name
    data = path.read_bytes() if path.exists() else urllib.request.urlopen(url, timeout=120).read()
    if hashlib.sha256(data).hexdigest() != digest:
        raise SystemExit(f"Checksum mismatch: {name}")
    path.write_bytes(data)
    if name.endswith(".tar.gz"):
        with tarfile.open(fileobj=io.BytesIO(data)) as archive:
            # Extract only regular files/directories under the pinned source root.
            for member in archive.getmembers():
                target = (root / member.name).resolve()
                if not target.is_relative_to(root) or member.issym() or member.islnk():
                    raise SystemExit("Unsafe archive entry")
                if member.isdir():
                    target.mkdir(parents=True, exist_ok=True)
                elif member.isfile():
                    target.parent.mkdir(parents=True, exist_ok=True)
                    target.write_bytes(archive.extractfile(member).read())
    print(f"Verified {name}")
