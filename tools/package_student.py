#!/usr/bin/env python3
"""Combine tested Windows/Linux artifacts without mixing stale native binaries."""
import argparse
from pathlib import Path
import subprocess
import zipfile
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--windows',type=Path,required=True)
p.add_argument('--linux',type=Path,required=True)
a=p.parse_args();root=Path(__file__).resolve().parents[1];student=root/'studentui'
files=subprocess.check_output(['git','ls-files','-z','studentui'],cwd=root).decode().split('\0')
destination=root/'dist/Grandiniu_LD-studentui.zip'
pending=destination.with_suffix('.zip.tmp')
with zipfile.ZipFile(pending,'w',zipfile.ZIP_DEFLATED) as out:
    for name in sorted(filter(None,files)):
        f=root/name;rel=f.relative_to(student)
        if f.suffix in {'.html','.sod','.log'}:continue
        if 'results' in rel.parts and f.name!='PATIKRA.json':continue
        out.write(f,'Grandiniu_LD-studentui/'+rel.as_posix())
    for platform,path,binaries in [('Windows',a.windows,['ldcore.dll','ldcheck.exe','mokytojas.exe']),('Linux',a.linux,['ldcore.so','ldcheck','mokytojas'])]:
        with zipfile.ZipFile(path) as source:
            for f in student.rglob('*'):
                if f.is_file() and f.suffix in {'.sci','.sce','.sh','.bat','.command'}:
                    assert source.read('Grandiniu_LD/'+f.relative_to(student).as_posix()).replace(b'\r\n',b'\n')==f.read_bytes().replace(b'\r\n',b'\n'),f'{platform}: stale {f}'
            for name in binaries:
                old=source.getinfo('Grandiniu_LD/bin/'+name)
                info=zipfile.ZipInfo('Grandiniu_LD-studentui/bin/'+name,date_time=old.date_time)
                info.external_attr=old.external_attr;info.compress_type=zipfile.ZIP_DEFLATED
                out.writestr(info,source.read(old))
    for f in sorted((root/'core/third_party').rglob('*')):
        if f.is_file():out.write(f,'Grandiniu_LD-studentui/third_party/'+f.name)
pending.replace(destination)
print('PASS: combined package uses matching source files and six tested native binaries')
