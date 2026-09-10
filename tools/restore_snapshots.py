from pathlib import Path
import base64
import hashlib
import zipfile

SETS = {
    "LD1_v1.7": (
        "LD1_Scilab_Virtuali_Laboratorija_v1.7.zip",
        "84841d6187caadf415e37e376bbcd8d055073e69260c441205e2fe6477b051c5",
        4,
    ),
    "LD2_v2.0": (
        "LD2_Scilab_Virtuali_Laboratorija_v2.0.zip",
        "2b87894ec3da67f501ec7ffa222907396e183cbee8f044dba649d2adb338f88b",
        14,
    ),
    "LD2_Auditas_2026-09-06": (
        "LD2_Auditas_2026-09-06.zip",
        "ed284a2485e3aa7496897cacd8bc29298ee5a86f9cb0e1c8454b7203cac3d347",
        7,
    ),
}

root = Path(__file__).resolve().parents[1]
snapshots = root / "snapshots"
out = root / "restored"
out.mkdir(exist_ok=True)

for dirname, (zipname, expected_sha, count) in SETS.items():
    folder = snapshots / dirname
    parts = [folder / f"part_{i:03d}.b64" for i in range(1, count + 1)]
    missing = [str(p) for p in parts if not p.exists()]
    if missing:
        raise SystemExit(f"Trūksta {dirname} dalių: {missing}")
    text = "".join(p.read_text(encoding="ascii").strip() for p in parts)
    data = base64.b64decode(text, validate=True)
    got = hashlib.sha256(data).hexdigest()
    if got != expected_sha:
        raise SystemExit(f"{zipname}: SHA-256 neatitinka: {got}")
    target = out / zipname
    target.write_bytes(data)
    with zipfile.ZipFile(target, "r") as zf:
        bad = zf.testzip()
        if bad:
            raise SystemExit(f"{zipname}: pažeistas ZIP narys: {bad}")
    print(f"OK  {zipname}  {got}")

print(f"Atkurti archyvai: {out}")
