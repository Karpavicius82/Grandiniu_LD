#!/usr/bin/env python3
"""MOKYTOJAS: append-mode IVERTINIMAI.csv, SHA-256 dedup, atsiliepimai, CLI klaidos."""
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from test_grading import fixture, write  # noqa: E402

BOM = b"\xef\xbb\xbf"


def run(exe, *args, cwd):
    env = dict(os.environ)
    env.pop("GRANDINIU_DRIVE_API_KEY", None)
    return subprocess.run([str(exe), *[str(a) for a in args]], cwd=str(cwd),
                          capture_output=True, text=True, env=env)


def rows(csv_path):
    data = csv_path.read_bytes()
    assert data[:3] == BOM, "CSV privalo prasidėti UTF-8 BOM"
    text = data[3:].decode("utf-8")
    out = []
    for line in text.split("\r\n"):
        if not line:
            continue
        # visi laukai cituojami csv() — saugus splitinimas per '";"'
        parts = line.split('";"')
        parts[0] = parts[0].lstrip('"')
        parts[-1] = parts[-1].rstrip('"')
        out.append(parts)
    return out


def main(exe):
    with tempfile.TemporaryDirectory() as td:
        work = Path(td)
        src = work / "pateikimai"
        src.mkdir()

        # 1) tobula LD1, klaidinga LD2 (blogas + trūkstamas atsakymas), šiukšlė, sugadinta
        perfect = fixture("LD1", 1, "mok-a")
        write(src / "a.html", perfect)

        bad = fixture("LD2", 17, "mok-b")
        bad["answers"][0]["raw"] = "999"
        bad["answers"] = bad["answers"][:-1]  # trūkstamas atsakymas
        write(src / "b.html", bad)

        (src / "c.txt").write_text("ne ataskaita", encoding="utf-8")
        (src / "d.html").write_text("<html>be duomenu</html>", encoding="utf-8")

        p = run(exe, src, cwd=work)
        assert p.returncode == 0, (p.returncode, p.stdout, p.stderr)
        csv_path = work / "IVERTINIMAI.csv"
        r = rows(csv_path)
        assert r[0] == ["Nr", "Data", "Studentas", "Grupė", "LD", "Variantas",
                        "Įvertinimas", "Balai", "Iš", "Klaidos", "Failas", "SHA256"], r[0]
        data = r[1:]
        assert len(data) == 3, data  # c.txt ignoruotas visai
        a, b, d = data
        assert a[4] == "LD1" and a[5] == "1" and float(a[6]) == 10.0 and a[7] == "22" and a[8] == "22", a
        assert a[9] == "" and a[10] == "a.html", a
        assert a[11] == hashlib.sha256((src / "a.html").read_bytes()).hexdigest(), "SHA-256 neatitinka hashlib"
        assert b[4] == "LD2" and b[5] == "17" and b[7] == "48" and b[8] == "50", b
        assert bad["answers"][0]["id"].split(".")[0] in b[9] or b[9] != "", b  # klaidos įvardintos
        assert d[6] == "NEVERTINTA" and "tinkami" in d[9], d
        # atsiliepimai: tik įvertintiems
        fb = sorted((work / "atsiliepimai").glob("*.txt"))
        assert len(fb) == 2, fb
        bad_fb = [f for f in fb if "LD2" in f.name][0].read_text(encoding="utf-8-sig")
        assert "tikėtasi" in bad_fb and "999" in bad_fb, bad_fb[:400]

        # 2) pakartotinis paleidimas — jokių dublikatų
        p = run(exe, src, cwd=work)
        assert p.returncode == 0, (p.stdout, p.stderr)
        assert len(rows(csv_path)) == 4, "pakartojimas pridėjo eilučių"
        assert "jau buvo ivertinti 3" in p.stdout, p.stdout

        # 3) naujas pateikimas — nauja eilutė, Nr tęsiasi, istorija lieka
        again = fixture("LD1", 1, "mok-c")
        write(src / "e.html", again)
        p = run(exe, src, cwd=work)
        assert p.returncode == 0, (p.stdout, p.stderr)
        r = rows(csv_path)
        assert len(r) == 5, len(r)  # antraštė + 4 duomenų
        assert r[4][0] == "4" and r[4][10] == "e.html", r[4]
        assert r[1][0] == "1", "senos eilutės turi likti"

        # 4) Data formatas
        assert len(r[4][1]) == 16 and r[4][1][4] == "-" and r[4][1][10] == " ", r[4][1]

        # 4b) ZURNALAS matrica: studentai eilutėse, LD stulpeliais
        zpath = work / "ZURNALAS.csv"
        assert zpath.is_file(), "ZURNALAS.csv turi būti sukurta"
        zr = rows(zpath)
        assert zr[0][:4] == ["Vardas", "Grupė", "LD1", "LD2"] and zr[0][-1] == "LD13", zr[0]
        assert len(zr) == 4, zr  # antraštė + 3 studentai (mok-a, mok-b, mok-c; d be identiteto)
        za = {r[0]: r for r in zr[1:]}
        a_row = za["Žąsė Ąžuolas mok-a"]
        assert a_row[2] == "10.0" and a_row[3] == "", a_row  # LD1 įvertinta, LD2 tuščia
        b_row = za["Žąsė Ąžuolas mok-b"]
        assert b_row[2] == "" and float(b_row[3]) > 0, b_row  # LD2 yra, LD1 dar ne

        # 4c) geriausias bandymas: tas pats studentas+LD du kartus — langelyje 10.0
        first_try = fixture("LD1", 2, "mok-d1")   # TOBULAS pateikiamas pirmas
        first_try["student"]["name"] = "Žąsė Įžuolas mok-b"
        write(src / "f1.html", first_try)
        second_try = fixture("LD1", 2, "mok-d2")   # prastesnis — vėliau
        second_try["student"]["name"] = "Žąsė Įžuolas mok-b"
        second_try["answers"][0]["raw"] = "1"
        write(src / "f2.html", second_try)
        p = run(exe, src, cwd=work)
        assert p.returncode == 0, (p.stdout, p.stderr)
        zr = rows(zpath)
        zb = {r[0]: r for r in zr[1:]}
        both = zb["Žąsė Įžuolas mok-b"]
        assert both[2] == "10.0", both  # geriausias iš dviejų bandymų
        assert len(rows(csv_path)) == 7, "žurnalas turi visus 6 pateikimus + antraštę"

        # 5) be rakto Drive nuoroda → exit 1 su aiškiu pranešimu
        p = run(exe, "https://drive.google.com/drive/folders/AbCdEfGhIjK123456789", cwd=work)
        assert p.returncode == 1, (p.returncode, p.stdout, p.stderr)
        assert "raktas" in (p.stderr + p.stdout).lower(), p.stderr

        # 6) neteisingi argumentai → exit 2
        p = run(exe, src, src, cwd=work)
        assert p.returncode == 2, p.returncode

    print(json.dumps({"status": "PASS", "tool": "mokytojas",
                      "checks": ["csv_append", "sha256_dedup", "klaidu_ivedimas",
                                 "atsiliepimai", "zurnalas_matrica", "geriausias_bandymas", "drive_be_rakto", "usage"]}))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
