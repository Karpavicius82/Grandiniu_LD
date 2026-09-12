#!/usr/bin/env python3
"""Independent analytical fixtures, complete batch + adversarial import tests."""
import copy
import csv
import ctypes
import json
import math
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time

START = '<script type="application/json" id="ld-data">'

def fixture(lab, n, identity):
    a, b = divmod(n - 1, 8)
    dc = [330, 470, 680, 820, 1000, 1200, 1500, 2200]
    r1, r2, r3 = dc[a], dc[b], dc[(a + b) % 8]
    r8 = [330, 470, 680, 820, 1000, 1200, 1500, 1800][a]
    r9 = [100, 150, 180, 220, 270, 330, 390, 470][b]
    l = [10, 12, 15, 18, 22, 27, 33, 39][a] * .001
    c = [47, 56, 68, 82, 100, 120, 150, 180][b] * 1e-9
    r13 = math.floor(math.sqrt(l / c) / (2.8 + .35 * (a + 1) + .20 * (b + 1)) + .5)
    frc, frl = 35 + 5 * (b + 1), 35 + 5 * (a + 1)
    report = dict(schema_version=1, lab_id=lab, lab_revision="1", rubric_version=lab + "-1",
                  bank_id=lab + "-64-A-2026", variant=n, submission_id=f"test-{identity}",
                  mode="assessment", student=dict(number=n, name=f"Žąsė Ąžuolas {identity}", group="EG-1"),
                  parameters={}, answers=[], observations=[], evidence={}, note="")
    def answer(step, q, value, unit):
        report["answers"].append(dict(id=f"s{step}.{q}", raw=format(value, ".12g"), unit=unit))
    def observation(key, value, unit):
        report["observations"].append(dict(id=key, value=value, unit=unit))
    def vector(step, values, units):
        for q, (value, unit) in enumerate(zip(values, units), 1):
            answer(step, "q" + str(q), value, unit)
    if lab == "LD1":
        report["parameters"] = dict(E=10, R1=r1, R2=r2, R3=r3)
        for step, vr in [(2, 1000), (4, 500)]:
            vector(step, [r1 + vr, 10000 / (r1 + vr)], ["Ohm", "mA"])
        vector(6, [r3 * (r2 + 1000) / (r3 + r2 + 1000)], ["Ohm"])
        vector(8, [10000/r3, 10000/r2, 10000/r3 + 10000/r2], ["mA"] * 3)
        answer(1, "type", 1, "choice"); answer(5, "type", 2, "choice")
        for step, value, unit in [(3, 10000/(r1+1000), "mA"), (4, 10000/(r1+500), "mA"),
                                  (6, 10, "V"), (7, 10, "V"), (8, 10000/r3+10000/r2, "mA")]:
            answer(step, "compare", 2 if step == 7 else 1, "choice")
            observation(f"s{step}.measure", value, unit)
        report["evidence"] = dict(realistic=False, wiring={
            "s1": dict(meter="A", pairs=[["SRC_P","R1_1"],["R1_2","VR1_1"],["VR1_2","M_P"],["M_N","SRC_N"]]),
            "s5": dict(meter="V", pairs=[["SRC_P","NODE_A1"],["SRC_N","NODE_B1"],
                ["NODE_A2","R3_1"],["R3_2","NODE_B2"],["NODE_A3","R2_1"],["R2_2","VR1_1"],
                ["VR1_2","NODE_B3"],["M_P","NODE_A4"],["M_N","NODE_B4"]])})
    elif lab == "LD3":
        rr = [33, 47, 56, 68, 82, 100, 120, 150][a]
        u1_, u2_, u3_ = [(3, 6, 9), (4, 8, 12), (2, 5, 8), (5, 10, 12),
                         (3, 7, 11), (6, 9, 12), (2, 6, 10), (4, 7, 10)][b]
        report["parameters"] = dict(R=rr, U1=u1_, U2=u2_, U3=u3_)
        vector(2, [u1_ / rr * 1000], ["mA"])
        for k, u in [(1, u1_), (2, u2_), (3, u3_)]:
            observation(f"u{k}", u, "V")
            observation(f"i{k}", u / rr * 1000, "mA")
        vector(4, [rr, rr, rr, rr], ["Ohm"] * 4)
        vector(5, [rr], ["Ohm"])
        vector(6, [1, 1], ["choice", "choice"])
        report["evidence"] = dict(wiring={"s1": [["E_P", "K1"], ["K2", "A_P"], ["A_N", "R1A"],
                                          ["R1B", "E_N"], ["V_P", "R1A"], ["V_N", "R1B"]]})
    else:
        report["parameters"] = dict(E_RC=9,F_RC=frc,R8=r8,C2=4.7e-6,E_RL=9,F_RL=frl,R9=r9,L1=.5,
                                    E_RLC=5,R13=r13,L3=l,C4=c)
        for step, resistance, f, reactive, prefix in [(3,r8,frc,-1/(2*math.pi*frc*4.7e-6),"rc_"),
                                                       (6,r9,frl,2*math.pi*frl*.5,"rl_")]:
            z=math.hypot(resistance,reactive); current=9/z; ur=current*resistance; ux=current*abs(reactive)
            vector(step,[abs(reactive),z,current*1000,ur,ux,current**2*resistance*1000,
                         -math.degrees(math.atan2(reactive,resistance))], ["Ohm","Ohm","mA","V","V","mW","deg"])
            vector(step+1,[9,current*1000],["V","mA"])
            for key,value,unit in [("I",current,"A"),("UR",ur,"V"),("UC" if step==3 else "UL",ux,"V"),("UE",9,"V")]:
                observation(prefix+key,value,unit)
        f0=1/(2*math.pi*math.sqrt(l*c)); bw=r13/(2*math.pi*l); q=2*math.pi*f0*l/r13
        disc=math.sqrt(r13*r13+4*l/c); f1=(-r13+disc)/(4*math.pi*l); f2=(r13+disc)/(4*math.pi*l)
        fl=f0/math.sqrt(1-r13*r13*c/(2*l)); fc=f0*math.sqrt(1-r13*r13*c/(2*l))
        def values(f):
            if f==0:return dict(UR=0,UL=0,UC=5,ULC=5)
            xl=2*math.pi*f*l; xc=1/(2*math.pi*f*c); current=5/math.hypot(r13,xl-xc)
            return dict(UR=current*r13,UL=current*xl,UC=current*xc,ULC=current*abs(xl-xc))
        resonance=[dict(f=f,u=values(f)["UR"]) for f in [f0-bw/2,f0,f0+bw/2]]
        peaks=[dict(target=t,f=f,u=values(f)[t]) for t,center in [("UL",fl),("UC",fc),("ULC",f0)] for f in [center-bw/2,center,center+bw/2]]
        vector(9,[f0,f0,1000/f0,5],["Hz","Hz","ms","V"])
        vector(10,[values(fl)["UL"],values(fc)["UC"],values(f0)["ULC"],fl,fc,f0],["V","V","V","Hz","Hz","Hz"])
        vector(11,[5/math.sqrt(2),f1,f2,bw,q],["V","Hz","Hz","Hz","1"])
        for key,value,unit in [("f1_meas",f1,"Hz"),("f2_meas",f2,"Hz"),("f1_u",5/math.sqrt(2),"V"),("f2_u",5/math.sqrt(2),"V")]:
            observation(key,value,unit)
        wiring={}
        for phase,first,second in [("RC","R8","C2"),("RL","R9","L1"),("RLC","C4","L3")]:
            wires=[["GEN_H","AM_H"],["AM_L",first+"_1"],[first+"_2",second+"_1"],[("R13" if phase=="RLC" else second)+"_2","GEN_L"]]
            if phase=="RLC":wires.append(["L3_2","R13_1"])
            wiring[phase]=wires
        report["evidence"]=dict(wiring=wiring,resonance=resonance,peaks=peaks,
            sweep=[dict(f=f,u=values(f)["UR"]) for f in range(0,10001,1000)],journal=[])
    return report

def write(path, report):
    encoded=json.dumps(report,ensure_ascii=False,allow_nan=False).replace("<","\\u003c")
    path.write_text('<!doctype html><meta charset="utf-8">'+START+encoded+'</script>',encoding="utf-8")

def run(exe, source, destination):
    start=time.monotonic()
    p=subprocess.run([str(exe),str(source),str(destination)],capture_output=True,text=True,timeout=90)
    assert p.returncode==0,p.stderr
    return json.loads((destination/"vertinimai.json").read_text(encoding="utf-8")),time.monotonic()-start

def main(exe):
    with tempfile.TemporaryDirectory(prefix="LD testai Žąsė ") as temp:
        root=Path(temp);source=root/"Studentų darbai";source.mkdir(); expected={}
        for i in range(650):
            lab="LD1" if i%2==0 else "LD2";r=fixture(lab,(i//2)%64+1,i);maximum=22 if lab=="LD1" else 50
            points=maximum
            if i%13==0:r["answers"][0]["raw"]="999999";points-=1
            if i%17==0:r["answers"][1]["raw"]="";points-=1
            # Untrusted suggested grades / completion flags must have no effect.
            r["suggested_grade"]=10;r["completed"]=[True]*12
            filename=f"{i:04d}.html";write(source/filename,r);expected[filename]=(points,maximum)
        data,seconds=run(exe,source,root/"Įvertinimai")
        assert data["complete"] and len(data["results"])==650
        for v in data["results"]:
            assert v["status"]=="graded",v
            assert (v["points"],v["max_points"])==expected[v["file"]],v
        replay,_=run(exe,source,root/"Pakartota")
        assert data==replay,"Nondeterministic replay"
        assert seconds<60,seconds
        adversarial=root/"Blogi failai";adversarial.mkdir();base=fixture("LD2",17,"good")
        mutations={
            "schema":lambda r:r.update(schema_version=99),
            "bool_variant":lambda r:r.update(variant=True),
            "range":lambda r:r.update(variant=65),
            "bank":lambda r:r.update(bank_id="changed"),
            "unit":lambda r:r["answers"][0].update(unit="A"),
            "config":lambda r:r["parameters"].update(R8=42),
            "duplicate_item":lambda r:r["answers"].append(r["answers"][0]),
            "unknown_item":lambda r:r["answers"].append(dict(id="unexpected",raw="1",unit="A")),
            "bad_points":lambda r:r["evidence"]["resonance"][0].update(f="exec()"),
        }
        for name,mutate in mutations.items():
            r=copy.deepcopy(base);mutate(r);write(adversarial/(name+".html"),r)
        (adversarial/"duplicate_key.html").write_text(START+'{"schema_version":1,"schema_version":1}</script>')
        (adversarial/"deep.html").write_text(START+'['*40+'0'+']'*40+'</script>')
        (adversarial/"large.html").write_text('x'*(2*1024*1024+1))
        (adversarial/"truncated.html").write_text(START+'{"schema_version":1')
        (adversarial/"senas.pdf").write_bytes(b'%PDF-1.4')
        r=copy.deepcopy(base);r["answers"][0]["raw"]="exec('secret')";r["answers"][1]["raw"]="1e999";r["submission_id"]="invalid-numbers"
        write(adversarial/"invalid_numbers.html",r)
        write(adversarial/"good.html",base);write(adversarial/"good_copy.html",base)
        data,_=run(exe,adversarial,root/"Blogų rezultatai")
        statuses=[v["status"] for v in data["results"]]
        assert statuses.count("review")==14,statuses
        assert statuses.count("graded")==2 and statuses.count("duplicate")==1,statuses
        inv=next(v for v in data["results"] if v["file"]=="invalid_numbers.html")
        assert inv["points"]==48
        # A conflicting ID invalidates both candidates, regardless of sorting.
        conflicts=root/"Konfliktai";conflicts.mkdir();write(conflicts/"a.html",base)
        changed=copy.deepcopy(base);changed["answers"][0]["raw"]="0";write(conflicts/"b.html",changed)
        data,_=run(exe,conflicts,root/"Konfliktų rezultatai")
        assert all(v["status"]=="conflict" and v["grade_10"] is None for v in data["results"])
        # Better valid attempt is selected; the weaker attempt remains visible.
        attempts=root/"Bandymai";attempts.mkdir();write(attempts/"a.html",base)
        changed["submission_id"]="new-attempt";write(attempts/"b.html",changed)
        data,_=run(exe,attempts,root/"Bandymų rezultatai")
        assert [v["selected_for_summary"] for v in data["results"]]==[True,False]
        # Runtime emits ordinary UTF-8 with a valid BOM for spreadsheet import.
        with (root/"Įvertinimai"/"suvestine.csv").open(encoding="utf-8-sig",newline="") as f:
            rows=list(csv.reader(f,delimiter=";"));assert rows[0][0]=="Failas" and len(rows)==651
        # LD3 (Omo dėsnis): savarankiškas scenarijus per tą patį ldcheck.
        ld3=root/"LD3 ataskaitos";ld3.mkdir()
        for n,name in [(1,"v1"),(17,"v17"),(64,"v64")]:
            write(ld3/(name+".html"),fixture("LD3",n,name))
        wrong=fixture("LD3",9,"w9");wrong["answers"][1]["raw"]="999";write(ld3/"blogas_r1.html",wrong)
        missing=fixture("LD3",25,"m25")
        missing["observations"]=[o for o in missing["observations"] if o["id"]!="i2"]
        write(ld3/"truksta_i2.html",missing)
        (ld3/"siunta.pdf").write_bytes(b'%PDF-1.4')
        data,_=run(exe,ld3,root/"LD3 rezultatai")
        assert data["complete"] and len(data["results"])==6,data
        by={v["file"]:v for v in data["results"]}
        for name in ("v1.html","v17.html","v64.html"):
            assert by[name]["status"]=="graded",by[name]
            assert (by[name]["points"],by[name]["max_points"])==(15,15),by[name]
        assert by["blogas_r1.html"]["status"]=="graded"
        assert (by["blogas_r1.html"]["points"],by["blogas_r1.html"]["max_points"])==(14,15)
        assert next(i for i in by["blogas_r1.html"]["items"] if i["id"]=="s4.q1")["status"]=="incorrect"
        assert (by["truksta_i2.html"]["points"],by["truksta_i2.html"]["max_points"])==(12,15)
        statuses={i["id"]:i["status"] for i in by["truksta_i2.html"]["items"]}
        assert statuses["i2"]=="missing" and statuses["s4.q2"]=="missing_evidence"
        assert statuses["s4.q4"]=="missing_evidence" and statuses["s4.q1"]=="correct"
        assert by["siunta.pdf"]["status"]=="review"
        with (root/"LD3 rezultatai"/"suvestine.csv").open(encoding="utf-8-sig",newline="") as f:
            assert len(list(csv.reader(f,delimiter=";")))==7
        print(json.dumps(dict(status="PASS",full_reports=650,seconds=round(seconds,3),adversarial_files=17,
                              deterministic_replay=True,conflicting_ids=True,multiple_attempts=True,utf8_paths=True,
                              ld3_batch=True)))

if __name__=="__main__":main(Path(sys.argv[1]).resolve())
