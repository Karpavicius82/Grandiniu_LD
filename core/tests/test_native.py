#!/usr/bin/env python3
"""Exercise the actual C ABI, independent three-phase/DC oracles, storage/cancel."""
import cmath
import ctypes as c
import json
import math
import os
from pathlib import Path
import sys
import tempfile
from test_grading import fixture,write

lib=c.CDLL(str(Path(sys.argv[1]).resolve()))
D=c.POINTER(c.c_double);I=c.POINTER(c.c_int)
lib.ld_mna.argtypes=[D,I,I,D,D,D,I]
lib.ld_write_new.argtypes=[I,I,I,I,I]
lib.ld_batch.argtypes=[I,I,I,I,I,D,I]
def solve(rows,n,f):
    m=len(rows);table=(c.c_double*(m*5))(*(rows[k][j] for j in range(5) for k in range(m)))
    vs=(c.c_double*((n+1)*2))();curr=(c.c_double*(m*2))();status=c.c_int(9)
    lib.ld_mna(table,c.byref(c.c_int(m)),c.byref(c.c_int(n)),c.byref(c.c_double(f)),vs,curr,c.byref(status))
    return status.value,[complex(vs[k],vs[n+1+k]) for k in range(n+1)],[complex(curr[k],curr[m+k]) for k in range(m)]
for delta in [False,True]:
    sources=[230*cmath.exp(1j*angle) for angle in [0,-2*math.pi/3,2*math.pi/3]]
    rows=[[4,k+1,0,v.real,v.imag] for k,v in enumerate(sources)]
    loads=[[1,1,2,100,0],[1,2,3,100,0],[1,3,1,100,0]] if delta else [[1,k+1,0,100,0] for k in range(3)]
    st,v,i=solve(rows+loads,3,50);assert st==0
    for measured,expected in zip(v[1:],sources):assert abs(measured-expected)<1e-9
    power=-sum((sources[k]*i[k].conjugate()).real for k in range(3))
    assert abs(power-(9 if delta else 3)*230**2/100)<1e-8
    assert abs(sum(i[:3]))<1e-10
# Unbalanced floating wye; independent neutral weighted-voltage formula.
resistors=[47,100,220]
rows=[[4,k+1,0,v.real,v.imag] for k,v in enumerate(sources)]+[[1,k+1,4,r,0] for k,r in enumerate(resistors)]
st,v,i=solve(rows,4,50);assert st==0
neutral=sum(x/r for x,r in zip(sources,resistors))/sum(1/r for r in resistors)
assert abs(v[4]-neutral)<1e-9 and abs(sum(i[3:]))<1e-10
# Multiple sources and DC limits.
st,v,i=solve([[4,1,0,10,0],[4,2,1,5,0],[1,2,0,100,0]],2,0)
assert st==0 and abs(v[2]-15)<1e-12 and abs(i[2]-.15)<1e-12
assert solve([[4,1,0,10,0],[4,1,0,12,0]],1,0)[0]==2
assert solve([[1,1,2,100,0]],2,50)[0]==2
assert solve([[1,999,0,100,0]],1,50)[0]==1
assert solve([[1,1,0,float('nan'),0]],1,50)[0]==1

def byte_array(s):
    b=s if isinstance(s,bytes) else str(s).encode('utf-8')
    return (c.c_int*len(b))(*b),c.c_int(len(b))
def new_file(path,contents):
    p,np=byte_array(path);b,nb=byte_array(contents);st=c.c_int(9)
    lib.ld_write_new(p,c.byref(np),b,c.byref(nb),c.byref(st));return st.value
def batch(cmd,source,dest):
    a,na=byte_array(source);b,nb=byte_array(dest);st=c.c_int(9);progress=(c.c_double*4)()
    lib.ld_batch(c.byref(c.c_int(cmd)),a,c.byref(na),b,c.byref(nb),progress,c.byref(st))
    return st.value,list(progress)
with tempfile.TemporaryDirectory(prefix='LD ABI Žąsė ') as temp:
    root=Path(temp);path=root/'nuliai.sod'
    assert new_file(path,b'one\0two')==0 and path.read_bytes()==b'one\0two'
    assert new_file(path,b'changed')<0 and path.read_bytes()==b'one\0two'
    assert new_file(root/'missing'/'test.html',b'data')<0
    if os.name!='nt':
        (root/'symlink.html').symlink_to(path)
        assert new_file(root/'symlink.html',b'data')<0
        protected=root/'protected';protected.mkdir();protected.chmod(0o500)
        try:assert new_file(protected/'test.html',b'data')<0
        finally:protected.chmod(0o700)
    source=root/'Ataskaitos';source.mkdir();dest=root/'Vertinimas'
    for k in range(50):write(source/f'{k:02d}.html',fixture('LD1',k%64+1,k))
    st,p=batch(1,source,dest);assert st==0 and p[:2]==[0,50]
    st,p=batch(2,source,dest);assert st==0 and p[:2]==[25,50]
    st,p=batch(3,source,dest);assert st==0
    result=json.loads((dest/'vertinimai.json').read_text(encoding='utf-8'))
    assert result['cancelled'] and not result['complete'] and len(result['results'])==25 and len(result['unprocessed'])==25
    assert batch(1,source,root/'Pakartotas')[0]==0
    assert batch(2,source,root/'Pakartotas')[0]==0
    assert batch(2,source,root/'Pakartotas')[0]==1
    assert batch(4,source,root/'Pakartotas')[0]==1
print('PASS: production C ABI, DC/multiple sources/wye/delta/floating neutral, atomic binary writes, cancel and replay')
