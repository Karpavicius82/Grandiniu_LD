#!/usr/bin/env python3
"""MOKYTOJAS UI: vietinis serveris per tikrą HTTP — puslapis, eiga, klaidos, uždarymas."""
import json
import os
import subprocess
import sys
import tempfile
import time
import urllib.request
import urllib.error
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from test_grading import fixture, write  # noqa: E402


def get(base, path, timeout=5):
    try:
        with urllib.request.urlopen(base + path, timeout=timeout) as r:
            return r.status, r.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8", "replace")


def main(exe):
    with tempfile.TemporaryDirectory() as td:
        work = Path(td)
        src = work / "darbai"
        src.mkdir()
        good = fixture("LD1", 3, "ui-a")
        write(src / "a.html", good)
        bad = fixture("LD2", 9, "ui-b")
        bad["answers"][0]["raw"] = "1"
        write(src / "b.html", bad)

        env = dict(os.environ)
        env["MOKYTOJAS_NO_BROWSER"] = "1"
        env.pop("GRANDINIU_DRIVE_API_KEY", None)
        proc = subprocess.Popen([str(exe), "--ui"], cwd=str(work), env=env,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        try:
            # portas iš pirmos stdout eilutės
            line = proc.stdout.readline()
            assert "MOKYTOJAS UI: http://127.0.0.1:" in line, line
            port = int(line.strip().rsplit(":", 1)[1])
            base = f"http://127.0.0.1:{port}"

            # 1) puslapis
            code, html = get(base, "/")
            assert code == 200 and "MOKYTOJAS" in html and "Įvertinti" in html, (code, html[:100])

            # 2) pradinė būsena
            code, body = get(base, "/status")
            s = json.loads(body)
            assert code == 200 and s["state"] == "idle" and not s["running"], s

            # 3) nežinomas maršrutas
            code, _ = get(base, "/nesamone")
            assert code == 404, code

            # 4) paleidimas su tikrom ataskaitom
            code, body = get(base, "/start?arg=" + urllib.request.quote(str(src)))
            assert code == 200 and json.loads(body)["ok"], (code, body)
            for _ in range(120):  # iki 30 s
                code, body = get(base, "/status")
                s = json.loads(body)
                if not s["running"]:
                    break
                time.sleep(0.25)
            assert s["state"] == "done" and s["total"] == 2, s

            # 5) pakartotinis paleidimas iškart po pabaigos — vėl ok (dedup viduje)
            code, body = get(base, "/start?arg=" + urllib.request.quote(str(src)))
            assert code == 200, (code, body)

            # 6) žurnalas matricoje
            code, csv = get(base, "/zurnalas")
            assert code == 200 and "Vardas" in csv and "LD1" in csv and "LD2" in csv, (code, csv[:80])
            assert (work / "IVERTINIMAI.csv").is_file() and (work / "ZURNALAS.csv").is_file()
            assert len(list((work / "atsiliepimai").glob("*.txt"))) == 2

            # 7) klaidos kelias: neegzistuojantis kelias
            code, body = get(base, "/start?arg=" + urllib.request.quote(str(work / "nieko")))
            for _ in range(40):
                code, body = get(base, "/status")
                s = json.loads(body)
                if not s["running"]:
                    break
                time.sleep(0.25)
            assert s["state"] == "error", s

            # 8) uždarymas per /quit — procesas baigiasi švariai
            code, body = get(base, "/quit")
            assert code == 200, (code, body)
            rc = proc.wait(timeout=10)
            assert rc == 0, rc
        finally:
            if proc.poll() is None:
                proc.kill()
    print(json.dumps({"status": "PASS", "tool": "mokytojas_ui",
                      "checks": ["puslapis", "statusas", "startas", "eigis", "zurnalas",
                                 "klaidos_kelias", "404", "uzdarymas"]}))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
