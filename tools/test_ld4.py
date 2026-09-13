#!/usr/bin/env python3
"""Internal feedback only: bounded native Scilab LD4 UI acceptance on both OSes."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--scilab', required=True, type=Path)
p.add_argument('--checker', required=True, type=Path)
p.add_argument('--core', type=Path)
p.add_argument('--output', required=True, type=Path)
a = p.parse_args()
repo = Path(__file__).resolve().parents[1]
out = a.output.resolve(); out.mkdir(parents=True, exist_ok=True)
runtime = out / 'runtime' / 'studentui'
shutil.copytree(repo / 'studentui', runtime, ignore=shutil.ignore_patterns('results', '__pycache__'))
(runtime / 'tests/results').mkdir(parents=True)
env = dict(os.environ, LD4_TEST_RUNTIME=runtime.as_posix(), LD4_TEST_OUT=out.as_posix(),
           LD4_TEST_SOURCE=repo.as_posix(), LD_DATA_DIR=(out / 'Ataskaitos Žąsė').as_posix())
if a.core: env['LD_CORE_LIBRARY'] = str(a.core.resolve())
exe = a.scilab.resolve()
if os.name == 'nt':
    exe = exe.parent / 'WScilex-cli.exe'
    assert exe.is_file(), f'Missing graphical Scilab executable: {exe}'
# Windows uses separate STD/NW/NWNI binaries, without -nw/-nwni flags.
mode = [] if os.name == 'nt' else ['-nw']
args = [str(exe), *mode, '-nb', '-f', str(repo / 'tools/test_ld4.sce')]
with (out / 'scilab.log').open('wb') as log:
    result = subprocess.run(args, env=env, stdout=log, stderr=subprocess.STDOUT, timeout=240)
verdict = (out / 'verdict.log').read_text(encoding='utf-8') if (out / 'verdict.log').exists() else (out / 'scilab.log').read_text(encoding='utf-8', errors='replace')
assert result.returncode == 0 and 'LD4_PASS:' in verdict, verdict
print(verdict.strip())
result = subprocess.run([str(a.checker.resolve()), str(out / 'geometry.tsv')], capture_output=True, text=True)
(out / 'geometry.log').write_text(result.stdout + result.stderr, encoding='utf-8')
print(result.stdout)
assert result.returncode == 0, 'LD4 geometry failed'
