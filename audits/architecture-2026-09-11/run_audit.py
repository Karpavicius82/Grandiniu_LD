#!/usr/bin/env python3
"""Reproduce bounded architecture probes; never marks industrial acceptance complete.

No downloads or installations. Build/output files live in a temporary directory.
Python is the test orchestrator, not a proposed student/teacher runtime dependency.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
import math
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import tarfile
import tempfile
import time

here = Path(__file__).resolve().parent
repo = here.parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--deps', type=Path, required=True)
parser.add_argument('--scilab', type=Path, required=True)
parser.add_argument('--sandbox-no-lsan', action='store_true', help='Disable LeakSanitizer under ptrace; ASan/UBSan remain enabled')
args = parser.parse_args()
work = Path(tempfile.mkdtemp(prefix='ld-architecture-audit-'))
evidence = here/'evidence'
evidence.mkdir(exist_ok=True)
records = []

def run(label, command, *, env=None, timeout=180):
    started = time.perf_counter()
    p = subprocess.run([str(x) for x in command], capture_output=True, text=True,
                       encoding='utf-8', errors='replace', timeout=timeout, env=env)
    seconds = round(time.perf_counter()-started, 3)
    (evidence/(label+'.log')).write_text(p.stdout+p.stderr, encoding='utf-8')
    records.append({'check': label, 'returncode': p.returncode, 'seconds': seconds})
    print(label, 'PASS' if p.returncode == 0 else 'FAIL', seconds, flush=True)
    if p.returncode:
        raise RuntimeError(label+': '+(p.stdout+p.stderr)[-4000:])
    return p.stdout

def decode_report(path):
    text=path.read_text(encoding='utf-8')
    return json.loads(text.split('<script type="application/json" id="ld-data">',1)[1].split('</script>',1)[0])

def wrap(record):
    return '<script type="application/json" id="ld-data">'+json.dumps(record,ensure_ascii=False).replace('<','\\u003c')+'</script>'

verdict = {'scope':'architecture feasibility only; not approved production software',
           'platform':platform.platform(), 'windows_runtime_tested':False,
           'time_utc':datetime.now(timezone.utc).isoformat(), 'work_dir':str(work)}
try:
    lock=json.loads((here/'dependencies.lock.json').read_text())
    for item in lock.values():
        assert hashlib.sha256((args.deps/item['file']).read_bytes()).hexdigest()==item['sha256'],item['file']
    with tarfile.open(args.deps/'eigen-5.0.0.tar.gz','r:gz') as archive:
        for member in archive.getmembers():
            if member.isfile() and member.name.startswith('eigen-5.0.0/Eigen/'):
                assert (args.deps/member.name).read_bytes()==archive.extractfile(member).read(),member.name
    run('configure', ['cmake','-S',here/'probes','-B',work,
                     '-DLD_AUDIT_DEPS='+str(args.deps.resolve()), '-DCMAKE_BUILD_TYPE=Debug'])
    run('build', ['cmake','--build',work,'--parallel','2'],timeout=300)
    san_env=os.environ.copy()
    if args.sandbox_no_lsan: san_env['ASAN_OPTIONS']='detect_leaks=0'
    verdict['leak_sanitizer_in_this_run']=not args.sandbox_no_lsan
    run('sanitizers', [work/'sanitizer_probe'],env=san_env)
    env = os.environ.copy(); env['LD_AUDIT_TMP']=str(work)
    text=run('scilab_boundaries', [args.scilab,'-nwni','-nb','-f',here/'probes/boundary_probe.sce'],env=env)
    assert 'SYNTHETIC_REPORT_EXPORT_PASS' in text
    verdict['numeric_checks']=int(re.search(r'checks=(\d+)',text).group(1))
    verdict['cpp_scilab_mna_comparisons']=int(re.search(r'CPP_MNA_COMPARISONS_PASS count=(\d+)',text).group(1))
    run('cpp_650_reports',[work/'report_probe',work/'reports',work/'grades.json'])
    grades=json.loads((work/'grades.json').read_text())
    assert len(grades)==650
    expected_counts=Counter()
    for row in grades:
        k=int(row['id'].split('-')[1])
        expected='missing' if k%17==0 else 'incorrect' if k%13==0 else 'correct'
        assert row['status']==expected,(k,row)
        assert row['points']==int(expected=='correct')
        expected_counts[expected]+=1
        if expected!='missing':
            v=(k-1)%64+1
            resistance=[330,470,680,820,1000,1200,1500,1800][(v-1)//8]
            frequency=35+5*((v-1)%8+1)
            current=9/math.hypot(resistance,1/(2*math.pi*frequency*4.7e-6))
            assert abs(row['reference_A']-current)<1e-12
    verdict['synthetic_650_report_results']=dict(expected_counts)
    # Exact replay is a required property, so this repetition is intentional.
    run('cpp_replay',[work/'report_probe',work/'reports',work/'replay.json'])
    assert (work/'grades.json').read_bytes()==(work/'replay.json').read_bytes()
    bad=work/'adversarial'; bad.mkdir()
    sample=decode_report(work/'reports/TEST-0001.html')
    cases={}
    def altered(name, mutate):
        record=json.loads(json.dumps(sample)); mutate(record)
        cases[name]=wrap(record)
    altered('01_future_version',lambda r:r.update(schema_version=999))
    altered('02_variant_bool',lambda r:r.update(variant=True))
    altered('03_variant_range',lambda r:r.update(variant=65))
    altered('04_wrong_unit',lambda r:r['answer'].update(unit='mA'))
    altered('05_expression',lambda r:r['answer'].update(value_SI='exec("anything")'))
    altered('06_missing_contract',lambda r:r['answer'].update(status='missing',value_SI=123))
    cases['07_duplicate_key']=wrap(sample).replace('"schema_version": 1','"schema_version": 1, "schema_version": 1')
    cases['08_nan']=wrap(sample).replace('"suggested_grade": 10','"suggested_grade": NaN')
    cases['09_oversize']='x'*(2*1024*1024+1)
    cases['10_truncated']=wrap(sample)[:-20]
    cases['11_deep']=wrap(sample).replace('"note": "', '"deep":'+('['*40)+'0'+(']'*40)+', "note": "',1)
    cases['12_duplicate_block']=wrap(sample)+wrap(sample)
    for name,content in cases.items(): (bad/(name+'.html')).write_text(content,encoding='utf-8')
    (bad/'20_valid.html').write_text(wrap(sample),encoding='utf-8')
    (bad/'21_duplicate_submission.html').write_text(wrap(sample),encoding='utf-8')
    run('cpp_adversarial',[work/'report_probe',bad,work/'adversarial.json'])
    rows=json.loads((work/'adversarial.json').read_text())
    counts=Counter(x['status'] for x in rows)
    assert counts=={'review':12,'correct':1,'duplicate':1},counts
    verdict['adversarial_results']=dict(counts)
    assert all('points' not in x for x in rows if x['status'] in {'review','duplicate'})
    run('existing_package',['python3',repo/'tools/check_student_package.py'])
    verdict['status']='FEASIBILITY_CHECKS_PASS_ACCEPTANCE_OPEN'
except Exception as error:
    verdict['status']='FAIL'; verdict['error']=str(error)
    raise
finally:
    verdict['runs']=records
    verdict['base_commit']=subprocess.run(['git','rev-parse','HEAD'],cwd=repo,capture_output=True,text=True).stdout.strip()
    verdict['source_sha256']={str(p.relative_to(here)):hashlib.sha256(p.read_bytes()).hexdigest()
                              for p in sorted((here/'probes').glob('*')) if p.is_file()}
    verdict['source_sha256']['run_audit.py']=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    verdict['source_sha256']['dependencies.lock.json']=hashlib.sha256((here/'dependencies.lock.json').read_bytes()).hexdigest()
    verdict['dependency_sha256']={name:hashlib.sha256((args.deps/name).read_bytes()).hexdigest()
                                 for name in ['eigen-5.0.0.tar.gz','json.hpp'] if (args.deps/name).is_file()}
    (evidence/'verdict.json').write_text(json.dumps(verdict,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print(json.dumps(verdict,ensure_ascii=False,indent=2))
