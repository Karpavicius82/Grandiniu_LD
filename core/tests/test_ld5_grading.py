#!/usr/bin/env python3
"""Internal LD5 acceptance: all variants and malformed measurement/wiring evidence."""
import copy
import json
from pathlib import Path
import sys
import tempfile
from test_grading import fixture, write, run


def main(exe):
    with tempfile.TemporaryDirectory(prefix='LD5 Žąsė ') as tmp:
        root = Path(tmp); source = root / 'Darbai'; source.mkdir(); expected = {}
        for n in range(1, 65):
            r = fixture('LD5', n, f'v{n}')
            # Endpoint order and measurement order must not affect grading.
            if n % 2:
                r['evidence']['wiring']['s1']['pairs'] = [w[::-1] for w in r['evidence']['wiring']['s1']['pairs'][::-1]]
                r['observations'].reverse()
            name = f'v{n:02d}.html'; write(source / name, r); expected[name] = 16
        for name in ['empty', 'extra_endpoint', 'missing_wire', 'duplicate_wire', 'wrong_probe', 'no_u2', 'wrong_u2', 'outside', 'inside']:
            r = fixture('LD5', 1, name); points = 15
            pairs = r['evidence']['wiring']['s1']['pairs']
            if name == 'empty':
                r['answers'] = []; r['observations'] = []; pairs.clear(); points = 0
            elif name == 'extra_endpoint': pairs[0].append('RVB')
            elif name == 'missing_wire': pairs.pop()
            elif name == 'duplicate_wire': pairs[-1] = copy.deepcopy(pairs[0])
            elif name == 'wrong_probe': pairs[-1] = ['V_N', 'R1A']
            elif name == 'no_u2': r['observations'] = [o for o in r['observations'] if o['id'] != 'u2']
            elif name == 'wrong_u2': next(o for o in r['observations'] if o['id'] == 'u2')['value'] = 0
            elif name in ['inside', 'outside']:
                r['answers'][0]['raw'] = format(float(r['answers'][0]['raw']) * (1.009 if name == 'inside' else 1.015), '.17g')
                if name == 'inside': points = 16
            filename = name + '.html'; write(source / filename, r); expected[filename] = points
        data, seconds = run(exe, source, root / 'Vertinimas')
        assert data['complete'] and len(data['results']) == len(expected), data
        for r in data['results']:
            assert r['status'] == 'graded' and r['max_points'] == 16, r
            assert r['points'] == expected[r['file']], r
        print(json.dumps(dict(status='PASS', variants=64, negative_and_boundary_cases=9, seconds=round(seconds, 3))))


if __name__ == '__main__': main(Path(sys.argv[1]).resolve())
