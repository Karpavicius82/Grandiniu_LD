import copy
import json
import math
from pathlib import Path
import sys
import tempfile
from test_grading import fixture, write, run


def variant_values(number):
    a, b = divmod(number - 1, 8)
    r1 = round([100, 120, 150, 180, 220, 270, 330, 390][a] * (1 + (number % 11 - 5) / 100) * 10) / 10
    r2 = round([470, 560, 680, 820, 1000, 1200, 1500, 1800][b] * (1 + ((3 * number) % 11 - 5) / 100) * 10) / 10
    r3 = round([220, 270, 330, 390, 470, 560, 680, 820][(a + b) % 8] * (1 + ((5 * number) % 11 - 5) / 100) * 10) / 10
    return r1, r2, r3


def main(executable):
    for number in range(1, 65):
        r1, r2, r3 = variant_values(number)
        series = r1 + r2 + r3
        parallel = 1 / (1 / r1 + 1 / r2 + 1 / r3)
        mixed = r1 + r2 * r3 / (r2 + r3)
        # Varžų jungimo dėsniai: serija didžiausia, lygiagretė mažiausia, mišri tarp jų.
        assert series > max(r1, r2, r3)
        assert parallel < min(r1, r2, r3)
        assert parallel < mixed < series
        i_series, i_parallel, i_mixed = (12 / x * 1000 for x in (series, parallel, mixed))
        assert i_parallel > i_mixed > i_series
        # Kirchhofo srovės dėsnis: šakų srovių suma lygi bendrai srovei.
        assert math.isclose(12 / r1 * 1000 + 12 / r2 * 1000 + 12 / r3 * 1000, i_parallel, rel_tol=1e-12)
    with tempfile.TemporaryDirectory(prefix='LD8 Žąsė ') as temporary:
        root = Path(temporary); folder = root / 'Darbai'; folder.mkdir(); expected = {}
        for number in range(1, 65):
            report = fixture('LD8', number, f'v{number}')
            for stage in report['evidence']['wiring'].values():
                if number % 2: stage['pairs'] = [pair[::-1] for pair in stage['pairs'][::-1]]
            filename = f'v{number:02d}.html'; write(folder/filename, report); expected[filename] = 21
        for stage in ['s1', 's3', 's4']:
            for damage in ['missing', 'duplicate', 'extra_endpoint']:
                name = f'{stage}-{damage}.html'; report = fixture('LD8', 1, name)
                pairs = report['evidence']['wiring'][stage]['pairs']
                if damage == 'missing': pairs.pop()
                elif damage == 'duplicate': pairs[-1] = copy.deepcopy(pairs[0])
                else: pairs[0].append('R3_B')
                write(folder/name, report); expected[name] = 20
        report = fixture('LD8', 64, 'empty')
        report['answers'] = []; report['observations'] = []; report['evidence']['wiring'] = {}
        write(folder/'empty.html', report); expected['empty.html'] = 0
        # Tolerancijų ribos: teorinė serijos varža ±(1±1e-4)·1 %.
        for name, factor in [('inside', 1.0099), ('outside', 1.0101)]:
            report = fixture('LD8', 17, name)
            answer = next(item for item in report['answers'] if item['id'] == 's2.q1')
            answer['raw'] = format(float(answer['raw']) * factor, '.17g')
            filename = f'boundary-{name}.html'; write(folder/filename, report)
            expected[filename] = 21 if name == 'inside' else 20
        # Matuota įtampa už absoliučios paklaidos ribos (0,005 V).
        report = fixture('LD8', 23, 'u-off')
        observation = next(item for item in report['observations'] if item['id'] == 'u2')
        observation['value'] += 0.006
        write(folder/'boundary-u.html', report); expected['boundary-u.html'] = 20
        results, seconds = run(executable, folder, root/'Vertinimas')
        assert len(results['results']) == len(expected)
        for result in results['results']:
            assert result['status'] == 'graded' and result['points'] == expected[result['file']], result
        print(json.dumps(dict(status='PASS', variants=64, graded_reports=len(expected),
                              resistance_laws=True, kirchhoff_current=True, seconds=round(seconds, 3))))


if __name__ == '__main__': main(Path(sys.argv[1]).resolve())
