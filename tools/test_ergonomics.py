#!/usr/bin/env python3
"""Internal feedback only: exercise Scilab UI and check pixel rectangles with C++."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--scilab", required=True)
    ap.add_argument("--output", required=True)
    ap.add_argument("--entrypoints-only", action="store_true")
    args = ap.parse_args()
    repo = Path(__file__).resolve().parents[1]
    output = Path(args.output).resolve()
    output.mkdir(parents=True, exist_ok=True)
    work = Path(tempfile.mkdtemp(prefix="runtime-", dir=output))
    runtime = work / "studentui"
    shutil.copytree(repo / "studentui", runtime)
    env = dict(os.environ, LD_ERGO_RUNTIME=str(runtime), LD_ENTRY_RUNTIME=str(runtime), LD_ERGO_OUT=str(output), LD_ERGO_SOURCE=str(repo))
    entry = subprocess.run([args.scilab, "-nw", "-nb", "-f", str(repo / "tools/test_entrypoints.sce")], env=env, capture_output=True, text=True, timeout=180)
    entry_log = entry.stdout + entry.stderr
    (output / "entrypoints.log").write_text(entry_log)
    if entry.returncode or "ENTRYPOINTS_PASS" not in entry_log:
        print(entry_log)
        return 1
    if args.entrypoints_only:
        print(entry_log)
        return 0
    checker = output / "layoutcheck"
    subprocess.run(["g++", "-std=c++17", "-Wall", "-Wextra", "-Wpedantic", "-O2", str(repo / "core/tests/layout_check.cpp"), "-o", str(checker)], check=True)
    subprocess.run([str(checker), "--self-test"], check=True)
    result = subprocess.run([args.scilab, "-nw", "-nb", "-f", str(repo / "tools/ergonomics.sce")], env=env, capture_output=True, text=True, timeout=600)
    log = result.stdout + result.stderr
    (output / "scilab.log").write_text(log)
    if result.returncode or "ERGONOMICS_PASS:" not in log:
        print(log)
        return 1
    result = subprocess.run([str(checker), str(output / "geometry.tsv")], capture_output=True, text=True, check=False)
    (output / "geometry.log").write_text(result.stdout + result.stderr)
    print(result.stdout + result.stderr)
    return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
