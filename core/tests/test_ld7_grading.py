import copy
import ctypes
import json
import math
from pathlib import Path
import sys
import tempfile
from test_grading import fixture, write, run


def match_reference(emf, internal, load):
    """U, I_mA of EMF behind internal resistance r feeding load R (closed form)."""
    current = emf / (load + internal)
    return [current * load, current * 1000]


def variant_values(number):
    a, b = divmod(number - 1, 8)
    emf = [3, 4, 5, 6, 7, 8, 10, 12][b]
    internal = [22, 27, 33, 39, 47, 56, 68, 82][a]
    load = [round(k * internal * 10) / 10 for k in [0.33, 0.56, 1.0, 1.8, 3.0]]
    return emf, internal, load


def main(executable, library):
    core = ctypes.CDLL(str(library)); scalar = ctypes.c_int
    vector = ctypes.c_double * 5; output_type = ctypes.c_double * 4
    core.ld_sources.argtypes = [ctypes.POINTER(scalar), ctypes.POINTER(ctypes.c_double),
                               ctypes.POINTER(ctypes.c_double), ctypes.POINTER(scalar)]
    mna_cases = 0
    for number in range(1, 65):
        emf, internal, load = variant_values(number)
        # Suderinamumo dėsnis: didžiausia galia būtent padėtyje P3 (R3 = r).
        power = [emf ** 2 * rr / (rr + internal) ** 2 for rr in load]
        assert max(power) == power[2] and load[2] == internal
        assert load[0] < internal < load[4]
        cases = load + [1e6, 1e-6]
        for rr in cases:
            output = output_type(); status = scalar(99)
            core.ld_sources(ctypes.byref(scalar(1)), vector(emf, emf, rr, internal, internal),
                            output, ctypes.byref(status))
            assert status.value == 0
            assert all(math.isclose(actual, expected, rel_tol=1e-10, abs_tol=1e-10)
                       for actual, expected in zip(output[:2], match_reference(emf, internal, rr)))
            voltage, load_current = output[0], output[1] / 1000
            source_current = output[2] / 1000
            assert math.isclose(source_current, load_current, abs_tol=1e-10)
            # Galios balansas: E·I = U·I + I²·r.
            assert math.isclose(emf * source_current,
                                voltage * load_current + source_current ** 2 * internal, abs_tol=1e-9)
            mna_cases += 1
    for inputs in [(0, 3, 100, 22, 22), (1, math.nan, 100, 22, 22), (1, 3, 0, 22, 22), (1, 3, 100, 0, 22)]:
        status = scalar(99); output = output_type()
        core.ld_sources(ctypes.byref(scalar(1)), vector(*inputs), output, ctypes.byref(status))
        assert status.value != 0
    with tempfile.TemporaryDirectory(prefix='LD7 Žąsė ') as temporary:
        root = Path(temporary); folder = root / 'Darbai'; folder.mkdir(); expected = {}
        for number in range(1, 65):
            report = fixture('LD7', number, f'v{number}')
            for stage in report['evidence']['wiring'].values():
                if number % 2: stage['pairs'] = [pair[::-1] for pair in stage['pairs'][::-1]]
            filename = f'v{number:02d}.html'; write(folder/filename, report); expected[filename] = 27
        for stage in ['s1', 's5te', 's5tj']:
            for damage in ['missing', 'duplicate', 'extra_endpoint']:
                name = f'{stage}-{damage}.html'; report = fixture('LD7', 1, name)
                pairs = report['evidence']['wiring'][stage]['pairs']
                if damage == 'missing': pairs.pop()
                elif damage == 'duplicate': pairs[-1] = copy.deepcopy(pairs[0])
                else: pairs[0].append('R_B')
                write(folder/name, report); expected[name] = 26
        report = fixture('LD7', 64, 'empty')
        report['answers'] = []; report['observations'] = []; report['evidence']['wiring'] = {}
        write(folder/'empty.html', report); expected['empty.html'] = 0
        # Tolerancijų ribos: Pmax atsakymas ±(1±1e-4)·2 %.
        for name, factor in [('inside', 1.019), ('outside', 1.021)]:
            report = fixture('LD7', 17, name)
            answer = next(item for item in report['answers'] if item['id'] == 's4.q4')
            answer['raw'] = format(float(answer['raw']) * factor, '.17g')
            filename = f'boundary-{name}.html'; write(folder/filename, report)
            expected[filename] = 27 if name == 'inside' else 26
        # TE matavimas už absoliučios paklaidos ribos (0,005 V).
        report = fixture('LD7', 23, 'te-off')
        observation = next(item for item in report['observations'] if item['id'] == 'te_u')
        observation['value'] += 0.006
        write(folder/'boundary-te.html', report); expected['boundary-te.html'] = 26
        results, seconds = run(executable, folder, root/'Vertinimas')
        assert len(results['results']) == len(expected)
        for result in results['results']:
            assert result['status'] == 'graded' and result['points'] == expected[result['file']], result
        print(json.dumps(dict(status='PASS', variants=64, mna_cases=mna_cases,
                              graded_reports=len(expected), power_balance=True,
                              matched_point=True, seconds=round(seconds, 3))))


if __name__ == '__main__': main(Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve())
