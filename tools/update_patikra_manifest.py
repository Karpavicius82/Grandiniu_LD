#!/usr/bin/env python3
"""Atnaujina studentui/tests/results/PATIKRA.json po runtime failu pasikeitimu.

Perskaiciuoja SHA256 visiems .sci/.sce/.sh failams po studentui/ (tas pats
aibes apibrezimas kaip check_student_package.py) ir surasa naujausiu
PATIKRINTI.sh zurnalu (tests/results/*.log) kontrolines sumas.

Naudoti Tik po sėkmingos pilnos patikros (PATIKRINTI.sh visi), kad manifestas
visada aprašytų išbandytą būseną.
"""
import argparse
import hashlib
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

RUNTIME_SUFFIXES = {".sci", ".sce", ".sh"}
LOGS = ["modelis.log", "langai.log"]


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def scilab_version(scilab_bin: str) -> str:
    try:
        out = subprocess.run([scilab_bin, "-nwni", "-nb", "-e", "disp(getversion());exit(0)"],
                             capture_output=True, text=True, timeout=120)
        first = next((l for l in out.stdout.splitlines() if l.strip()), "")
        return f"{first.strip()} {sys.platform}"
    except Exception:
        return "unknown"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--root", default=str(Path(__file__).resolve().parents[1]))
    ap.add_argument("--scilab", default="scilab", help="Scilab paleidėjas versijos užrašui")
    ap.add_argument("--command", default="./PATIKRINTI.sh")
    ap.add_argument("--status", default="PASS", choices=["PASS", "FAIL"])
    args = ap.parse_args()

    student = Path(args.root) / "studentui"
    results = student / "tests" / "results"
    manifest_path = results / "PATIKRA.json"

    runtime = sorted(str(p.relative_to(student)) for p in student.rglob("*")
                     if p.is_file() and p.suffix in RUNTIME_SUFFIXES)
    source = {name: sha256((student / name).read_bytes()) for name in runtime}

    log_hashes = {}
    for log in LOGS:
        p = results / log
        if p.exists():
            log_hashes[log] = sha256(p.read_bytes())

    old = json.loads(manifest_path.read_text()) if manifest_path.exists() else {}
    manifest = {
        "time_utc": datetime.now(timezone.utc).isoformat(),
        "scilab": scilab_version(args.scilab),
        "command": args.command,
        "status": args.status,
        "coverage": old.get("coverage", {}),
        "source_sha256": source,
        "log_sha256": log_hashes,
    }
    manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")
    print(f"PASS: PATIKRA.json atnaujintas ({len(source)} runtime failų, "
          f"{len(log_hashes)} žurnalų)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
