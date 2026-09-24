import copy
import csv
import json
import math
from pathlib import Path
import sys
import tempfile
from test_grading import fixture, write, run


def variant_values(number):
    a, b = divmod(number - 1, 8)
    l = [10, 12, 15, 18, 22, 27, 33, 39][a] * 1e-3
    c = [47, 56, 68, 82, 100, 120, 150, 180][b] * 1e-9
    qt = 2.0 + 0.5 * ((a + b) % 4)
    r = round(100 * math.sqrt(l / c) / qt) / 100
    return l, c, r


def main(executable):
    with (Path(__file__).resolve().parents[2] / 'studentui/LD9/VARIANTAI.csv').open(encoding='utf-8') as bank:
        rows=list(csv.DictReader(bank, delimiter=';'))
    assert len(rows)==64
    for number,row in enumerate(rows,1):
        l,c,r=variant_values(number)
        assert row['Variantas']==f'LD9-V{number:02}' and float(row['E_V_RMS'])==5
        for name,value in [('R_Ohm',r),('L_H',l),('C_F',c),('L_mH',l*1e3),('C_nF',c*1e9)]:
            assert math.isclose(float(row[name]),value,rel_tol=1e-12), (number,name)
    for number in range(1, 65):
        l, c, r = variant_values(number)
        f0 = 1 / (2 * math.pi * math.sqrt(l * c))
        # Rezonansas matomoje juostoje ir išreikšta įtampų resonanso savybė.
        assert 500 < f0 < 25000, (number, f0)
        q = math.sqrt(l / c) / r
        assert 1.5 <= q <= 5.5, (number, q)
        # Ties f0: Z = R (minimalus), UL = UC, Q = UL/E.
        zz = math.hypot(r, 2 * math.pi * f0 * l - 1 / (2 * math.pi * f0 * c))
        assert abs(zz - r) <= 1e-9 * r
    with tempfile.TemporaryDirectory(prefix='LD9 Žąsė ') as temporary:
        root = Path(temporary); folder = root / 'Darbai'; folder.mkdir(); expected = {}
        for number in range(1, 65):
            report = fixture('LD9', number, f'v{number}')
            if number % 2:
                stage = report['evidence']['wiring']['s1']
                stage['pairs'] = [pair[::-1] for pair in stage['pairs'][::-1]]
            filename = f'v{number:02d}.html'; write(folder/filename, report); expected[filename] = 28
        for damage in ['missing', 'duplicate', 'extra_endpoint']:
            name = f's1-{damage}.html'; report = fixture('LD9', 1, name)
            pairs = report['evidence']['wiring']['s1']['pairs']
            if damage == 'missing': pairs.pop()
            elif damage == 'duplicate': pairs[-1] = copy.deepcopy(pairs[0])
            else: pairs[0].append('C_B')
            write(folder/name, report); expected[name] = 27
        report = fixture('LD9', 64, 'empty')
        report['answers'] = []; report['observations'] = []; report['evidence']['wiring'] = {}
        write(folder/'empty.html', report); expected['empty.html'] = 0
        # Tolerancijų ribos: f0 ±(1±1e-4)·1 % ir teorinė Q ±(1±1e-4)·3 %.
        for key, ident, tolerance in [('s1.q1', 'f0', .01), ('s3.q1', 'q', .03)]:
            base = None
            report = fixture('LD9', 17, key)
            answer = next(item for item in report['answers'] if item['id'] == key)
            base = float(answer['raw'])
            if ident == 'q':
                l, c, r = variant_values(17)
                base = math.sqrt(l / c) / r
            for name, factor in [('in', 1 + tolerance * .999), ('out', 1 + tolerance * 1.001)]:
                report = fixture('LD9', 17, f'{key}-{name}')
                answer = next(item for item in report['answers'] if item['id'] == key)
                answer['raw'] = format(base * factor, '.17g')
                filename = f'{key}-{name}.html'; write(folder/filename, report)
                expected[filename] = 28 if name == 'in' else 27
        results, seconds = run(executable, folder, root/'Vertinimas')
        assert len(results['results']) == len(expected)
        for result in results['results']:
            assert result['status'] == 'graded' and result['points'] == expected[result['file']], result
        print(json.dumps(dict(status='PASS', variants=64, graded_reports=len(expected),
                              resonance_bounds=True, quality_factor=True, seconds=round(seconds, 3))))


if __name__ == '__main__': main(Path(sys.argv[1]).resolve())
