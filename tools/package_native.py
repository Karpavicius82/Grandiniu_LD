#!/usr/bin/env python3
import argparse
from pathlib import Path
import zipfile
p=argparse.ArgumentParser();p.add_argument('--platform',choices=['Windows','Linux'],required=True);a=p.parse_args()
root=Path(__file__).resolve().parents[1];source=root/'studentui'
ext='.dll' if a.platform=='Windows' else '.so'
assert (source/'bin'/('ldcore'+ext)).is_file()
assert (source/'bin'/('ldcheck.exe' if a.platform=='Windows' else 'ldcheck')).is_file()
assert (source/'bin'/('mokytojas.exe' if a.platform=='Windows' else 'mokytojas')).is_file()
dest=root/'dist'/f'Grandiniu_LD-{a.platform}.zip';dest.parent.mkdir(exist_ok=True)
with zipfile.ZipFile(dest,'w',zipfile.ZIP_DEFLATED) as z:
    for f in sorted(source.rglob('*')):
        if not f.is_file() or f.suffix=='.sod' or 'results' in f.relative_to(source).parts:continue
        if f.suffix=='.html':continue
        z.write(f,'Grandiniu_LD/'+f.relative_to(source).as_posix())
    for f in sorted((root/'core/third_party').rglob('*')):
        if f.is_file():z.write(f,'Grandiniu_LD/third_party/'+f.relative_to(root/'core/third_party').as_posix())
print(dest)
