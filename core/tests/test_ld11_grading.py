import copy
import csv
import ctypes as ct
import json
import math
from pathlib import Path
import sys
import tempfile
from test_grading import fixture, write, run


def variant_values(number):
    a, b = divmod(number - 1, 8)
    e = [5, 6, 7, 8, 9, 10, 11, 12][b]
    r = [10, 15, 22, 33, 47, 68, 82, 100][a]
    l = [100, 150, 220, 330, 470, 680, 1000, 1500][(a + b) % 8] * 1e-3
    w = 2 * math.pi * 50
    xl = w * l
    ck = round(xl / (w * (r * r + xl * xl)) * 1e8) / 1e8
    return e, r, l, ck


def check_native(library):
    lib=ct.CDLL(str(library))
    lib.ld_ac.argtypes=[ct.POINTER(ct.c_int),ct.POINTER(ct.c_double),ct.POINTER(ct.c_double),ct.POINTER(ct.c_int)]
    def solve(params):
        kind=ct.c_int(5); status=ct.c_int(99); result=(ct.c_double*10)()
        lib.ld_ac(ct.byref(kind),(ct.c_double*5)(*params),result,ct.byref(status))
        return status.value,list(result)
    with (Path(__file__).resolve().parents[2]/'studentui/LD11/VARIANTAI.csv').open(encoding='utf-8') as f:
        rows=list(csv.DictReader(f,delimiter=';'))
    assert len(rows)==64
    for number,row in enumerate(rows,1):
        e,r,l,ck=variant_values(number);w=2*math.pi*50;xl=w*l
        assert row['Variantas']==f'LD11-V{number:02}'
        for key,value in [('E_V_RMS',e),('f_Hz',50),('R_Ohm',r),('L_H',l),('L_mH',l*1e3),('Ck_F',ck),('Ck_uF',ck*1e6)]:
            assert math.isclose(float(row[key]),value,rel_tol=1e-12),(number,key)
        for cap in [0,ck,2*ck]:
            y=1/complex(r,xl)+complex(0,w*cap);current=e*y;power=e*current.conjugate()
            expected=[xl,abs(complex(r,xl)),r/abs(complex(r,xl)),abs(current),e/abs(complex(r,xl)),power.real,power.imag,e*abs(current),math.degrees(math.atan2(power.imag,power.real)),e*w*cap]
            status,actual=solve([e,50,r,l,cap]);assert status==0
            for index,(a,b) in enumerate(zip(actual,expected)):
                assert math.isclose(a,b,rel_tol=1e-10,abs_tol=1e-10),(number,cap,index,a,b)
    for index,bad in [(0,float('nan')),(1,0),(1,-1),(2,0),(3,0),(4,-1),(4,float('inf'))]:
        params=[5,50,10,.1,0];params[index]=bad;assert solve(params)[0]!=0


def main(executable):
    for number in range(1, 65):
        e, r, l, ck = variant_values(number)
        w = 2 * math.pi * 50
        xl = w * l
        z = math.hypot(r, xl)
        cos0 = r / z
        # Kompensacija visada pagerina cos φ ir sumažina pilnutinę galią.
        assert 0.02 <= cos0 <= 0.98, (number, cos0)
        i1 = e / z
        # Nuoseklaus RIŠLĖS laidis: G = R/Z², B = −XL/Z² (ne 1/XL!).
        admittance = complex(r / (z * z), xl / (z * z) - w * ck)
        i2 = e * abs(admittance)
        assert i2 < i1 + 1e-12, (number, i1, i2)
        p = e * i1 * cos0
        assert 1e-4 <= ck * 1e6 <= 500.0, (number, ck * 1e6)
    with tempfile.TemporaryDirectory(prefix='LD11 Žąsė ') as temporary:
        root = Path(temporary); folder = root / 'Darbai'; folder.mkdir(); expected = {}
        for number in range(1, 65):
            report = fixture('LD11', number, f'v{number}')
            if number % 2:
                for stage in report['evidence']['wiring'].values():
                    stage['pairs'] = [pair[::-1] for pair in stage['pairs'][::-1]]
            filename = f'v{number:02d}.html'; write(folder/filename, report); expected[filename] = 20
        # Evaluate calculations made from precisely what the student can see.
        for number in range(1,65):
            report=fixture('LD11',number,f'display-{number}')
            e,r,l,ck=variant_values(number); w=2*math.pi*50
            y1=1/complex(r,w*l);y2=y1+complex(0,w*ck)
            p=round(e*e*y1.real*1000,6)
            s1=e*round(e*abs(y1)*1000,6);s2=e*round(e*abs(y2)*1000,6)
            q1=math.sqrt(max(0,s1*s1-p*p));q2=abs(q1-1000*w*ck*e*e)
            values={'s2.q1':s1,'s2.q2':q1,'s2.q3':p/s1,'s5.q1':s2,'s5.q2':q2,'s5.q3':p/s2,'s5.q4':s1-s2}
            for answer in report['answers']:
                if answer['id'] in values:answer['raw']=format(values[answer['id']],'.17g')
            # New return node is electrically identical; old fixtures remain tested above.
            pairs=report['evidence']['wiring']['s4']['pairs']
            for index,pair in enumerate(pairs):
                if set(pair)=={'C_B','GEN_N'}:pairs[index]=['C_B','RL_B']
            filename=f'display-{number:02}.html';write(folder/filename,report);expected[filename]=20
        for stage in ['s1', 's4']:
            for damage in ['missing', 'duplicate', 'extra_endpoint']:
                name = f'{stage}-{damage}.html'; report = fixture('LD11', 1, name)
                pairs = report['evidence']['wiring'][stage]['pairs']
                if damage == 'missing': pairs.pop()
                elif damage == 'duplicate': pairs[-1] = copy.deepcopy(pairs[0])
                else: pairs[0].append('GEN_N')
                write(folder/name, report); expected[name] = 19
        report = fixture('LD11', 64, 'empty')
        report['answers'] = []; report['observations'] = []; report['evidence']['wiring'] = {}
        write(folder/'empty.html', report); expected['empty.html'] = 0
        for key, tolerance in [('s3.q1', .03), ('s1.q1', .01)]:
            report = fixture('LD11', 17, key)
            answer = next(item for item in report['answers'] if item['id'] == key)
            base = float(answer['raw'])
            for name, factor in [('in', 1 + tolerance * .999), ('out', 1 + tolerance * 1.001)]:
                report = fixture('LD11', 17, f'{key}-{name}')
                answer = next(item for item in report['answers'] if item['id'] == key)
                answer['raw'] = format(base * factor, '.17g')
                filename = f'{key}-{name}.html'; write(folder/filename, report)
                expected[filename] = 20 if name == 'in' else 19
        results, seconds = run(executable, folder, root/'Vertinimas')
        assert len(results['results']) == len(expected)
        for result in results['results']:
            assert result['status'] == 'graded' and result['points'] == expected[result['file']], result
        print(json.dumps(dict(status='PASS', variants=64, graded_reports=len(expected),
                              compensation_improves=True, active_power_kept=True, seconds=round(seconds, 3))))


if __name__ == '__main__':
    check_native(Path(sys.argv[2]).resolve())
    main(Path(sys.argv[1]).resolve())
