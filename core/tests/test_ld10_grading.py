import copy
import ctypes as ct
import csv
import json
import math
from pathlib import Path
import sys
import tempfile
from test_grading import fixture, write, run


def variant_values(number):
    a, b = divmod(number - 1, 8)
    l = [10, 12, 15, 18, 22, 27, 33, 39][b] * 1e-3
    c = [47, 56, 68, 82, 100, 120, 150, 180][a] * 1e-9
    qt = 2.0 + 0.5 * ((a + b) % 4)
    r = round(100 * qt * math.sqrt(l / c)) / 100
    return l, c, r


def check_native(library):
    lib=ct.CDLL(str(library))
    lib.ld_ac.argtypes=[ct.POINTER(ct.c_int),ct.POINTER(ct.c_double),ct.POINTER(ct.c_double),ct.POINTER(ct.c_int)]
    def solve(params):
        kind=ct.c_int(4); status=ct.c_int(99); output=(ct.c_double*10)()
        lib.ld_ac(ct.byref(kind),(ct.c_double*5)(*params),output,ct.byref(status))
        return status.value,list(output)
    for number in range(1,65):
        l,c,r=variant_values(number); f0=1/(2*math.pi*math.sqrt(l*c))
        for ratio in [.5,1,2]:
            f=ratio*f0; w=2*math.pi*f; xl=w*l; xc=1/(w*c)
            ir=5/r; il=5/xl; ic=5/xc; total=math.hypot(ir,ic-il)
            expected=[xl,xc,5/total,total,ir,il,ic,abs(il-ic),25/r,math.degrees(math.atan2(il-ic,ir))]
            status,actual=solve([5,f,r,l,c]); assert status==0
            for index,(a,b) in enumerate(zip(actual,expected)):
                assert math.isclose(a,b,rel_tol=1e-10,abs_tol=1e-10),(number,ratio,index,a,b)
    for index,bad in [(0,float('nan')),(1,0),(1,-1),(2,0),(3,0),(4,0),(4,float('inf'))]:
        params=[5,1000,1000,.01,1e-7];params[index]=bad
        assert solve(params)[0]!=0,(index,bad)


def main(executable):
    with (Path(__file__).resolve().parents[2] / 'studentui/LD10/VARIANTAI.csv').open(encoding='utf-8') as bank:
        rows=list(csv.DictReader(bank, delimiter=';'))
    assert len(rows)==64
    for number,row in enumerate(rows,1):
        l,c,r=variant_values(number)
        assert row['Variantas']==f'LD10-V{number:02}' and float(row['E_V_RMS'])==5
        for name,value in [('R_Ohm',r),('L_H',l),('C_F',c),('L_mH',l*1e3),('C_nF',c*1e9)]:
            assert math.isclose(float(row[name]),value,rel_tol=1e-12), (number,name)
    for number in range(1, 65):
        l, c, r = variant_values(number)
        f0 = 1 / (2 * math.pi * math.sqrt(l * c))
        assert 500 < f0 < 25000, (number, f0)
        # Srovių kokybė Q = IL/I0 = R/XL0 = R·sqrt(C/L) > 1,5 visuose variantuose.
        q = r * math.sqrt(c / l)
        assert 1.5 <= q <= 5.5, (number, q)
        # Ties f0: bendroji srovė mažiausia ir lygi IR (cos φ = 1).
        currents = []
        for k in [0.5, 1.0, 2.0]:
            f = k * f0
            xl = 2 * math.pi * f * l
            xc = 1 / (2 * math.pi * f * c)
            currents.append(5 * abs(complex(1 / r, 1 / xl - 1 / xc)))
        assert currents[1] < currents[0] and currents[1] < currents[2]
        assert math.isclose(currents[1], 5 / r, rel_tol=1e-12)
    with tempfile.TemporaryDirectory(prefix='LD10 Žąsė ') as temporary:
        root = Path(temporary); folder = root / 'Darbai'; folder.mkdir(); expected = {}
        for number in range(1, 65):
            report = fixture('LD10', number, f'v{number}')
            if number % 2:
                stage = report['evidence']['wiring']['s1']
                stage['pairs'] = [pair[::-1] for pair in stage['pairs'][::-1]]
            filename = f'v{number:02d}.html'; write(folder/filename, report); expected[filename] = 28
        for damage in ['missing', 'duplicate', 'extra_endpoint']:
            name = f's1-{damage}.html'; report = fixture('LD10', 1, name)
            pairs = report['evidence']['wiring']['s1']['pairs']
            if damage == 'missing': pairs.pop()
            elif damage == 'duplicate': pairs[-1] = copy.deepcopy(pairs[0])
            else: pairs[0].append('C_B')
            write(folder/name, report); expected[name] = 27
        report = fixture('LD10', 64, 'empty')
        report['answers'] = []; report['observations'] = []; report['evidence']['wiring'] = {}
        write(folder/'empty.html', report); expected['empty.html'] = 0
        # Tolerancijų ribos: f0 ±(1±1e-4)·1 % ir srovių kokybė ±(1±1e-4)·3 %.
        for key in ['s1.q1', 's3.q1']:
            report = fixture('LD10', 17, key)
            answer = next(item for item in report['answers'] if item['id'] == key)
            base = float(answer['raw'])
            tolerance = .01 if key == 's1.q1' else .03
            for name, factor in [('in', 1 + tolerance * .999), ('out', 1 + tolerance * 1.001)]:
                report = fixture('LD10', 17, f'{key}-{name}')
                answer = next(item for item in report['answers'] if item['id'] == key)
                answer['raw'] = format(base * factor, '.17g')
                filename = f'{key}-{name}.html'; write(folder/filename, report)
                expected[filename] = 28 if name == 'in' else 27
        results, seconds = run(executable, folder, root/'Vertinimas')
        assert len(results['results']) == len(expected)
        for result in results['results']:
            assert result['status'] == 'graded' and result['points'] == expected[result['file']], result
        print(json.dumps(dict(status='PASS', variants=64, graded_reports=len(expected),
                              current_resonance=True, minimum_total_current=True, seconds=round(seconds, 3))))


if __name__ == '__main__':
    check_native(Path(sys.argv[2]).resolve())
    main(Path(sys.argv[1]).resolve())
