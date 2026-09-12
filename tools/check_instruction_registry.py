#!/usr/bin/env python3
"""Instrukcijų <-> registrų konsistencijos patikra (audito kokybės baras).

Kiekviena [kodo] nuoroda instrukcijose (pvz. [T07], [B12], [A03.01]) .sci/.sce
failuose po studentui/ turi egzistuoti kodų registre:
studentui/LD1/ld1_ids.sci, studentui/LD2/ld2_ids.sci arba studentui/LD3/ld3_ids.sci.
Kitu atveju CI krenta tiek Linux, tiek Windows.

Registre turi būti deklaratyvi eilutė su markeriu „REGISTRY-CODES:" —
tarpais atskirtų diapazonų sąrašas: T01:T38, B01:B45, A03.01:A03.07, V01.
Ši eilutė — statinė tiesa šiai patikrai (ctest be Scilab). Runtime atitikimą
(deklaracija == ld*_all_codes()) papildomai tikrina studentui/tests/HEADLESS.sce,
todėl deklaracijos ir generatoriaus divergencija yra neįmanoma.

Exit kodai: 0 = OK, 1 = rasta klaidų, 2 = konfigūracijos trūkumas
(registro failas nerastas).
Savitikra: python3 tools/check_instruction_registry.py --self-test
"""
import argparse
import re
import shutil
import sys
import tempfile
from pathlib import Path

# Galiojantis kodas: viena raidė iš T/B/E/F/V/H/D/W + 2 skaitmenys,
# arba A + 2 skaitmenys + taškas + 2 skaitmenys (A03.01).
CODE_PATTERN = r"(?:[TBEFVHDW]\d{2}|A\d{2}\.\d{2})"
CODE_FULL_RE = re.compile(r"^" + CODE_PATTERN + r"$")
REF_RE = re.compile(r"\[(" + CODE_PATTERN + r")\]")  # atmintinės nuoroda: [kodo]

DECLARED_MARKER = "REGISTRY-CODES:"
# Diapazono tokenai: T01:T38 (ta pati raidė) arba A03.01:A03.07 (tas pats etapas).
RANGE_RE = re.compile(r"^([TBHEFVWD])(\d{2}):([TBHEFVWD])(\d{2})$")
A_RANGE_RE = re.compile(r"^A(\d{2})\.(\d{2}):A(\d{2})\.(\d{2})$")

# Registrų failai pagal LD (keliai nuo repo šaknies). Vienintelis runtime —
# studentui medis; root LD1/, LD2/ archyvuoti (istorija github'e).
REGISTRIES = [("LD1", "studentui/LD1/ld1_ids.sci"), ("LD2", "studentui/LD2/ld2_ids.sci"),
             ("LD3", "studentui/LD3/ld3_ids.sci")]
SCAN_DIRS = ("studentui",)  # kur ieškome [kodo] nuorodų
SCAN_SUFFIXES = (".sci", ".sce")


def string_literals(line):
    """Visi dvigubomis kabutėmis apausti literalai vienoje eilutėje (Scilab: \"\" = kabutė)."""
    out, i, n = [], 0, len(line)
    while i < n:
        start = line.find('"', i)
        if start < 0:
            break
        i = start + 1
        chunks = []
        while True:
            j = line.find('"', i)
            if j < 0:  # neuždaryta kabutė — imam iki eilutės galo
                chunks.append(line[i:])
                i = n
                break
            if j + 1 < n and line[j + 1] == '"':  # "" — escapeintas kabutės ženklas
                chunks.append(line[i:j + 1])
                i = j + 2
            else:
                chunks.append(line[i:j])
                i = j + 1
                break
        out.append("".join(chunks))
    return out


def strip_comment(line):
    """Nukerta // komentarą (tik už kabučių — kabutėse // gali būti tekstas)."""
    i, n = 0, len(line)
    while i < n:
        ch = line[i]
        if ch == '"':  # praleidžiam string literalą (su "" escape)
            i += 1
            while i < n:
                if line[i] == '"':
                    if i + 1 < n and line[i + 1] == '"':
                        i += 2
                        continue
                    i += 1
                    break
                i += 1
        elif ch == "/" and i + 1 < n and line[i + 1] == "/":
            return line[:i]
        else:
            i += 1
    return line


def read_text(path):
    # Scilab failai UTF-8; keisti baitai neturi sugriauti patikros.
    return path.read_text(encoding="utf-8", errors="replace")


def msprintf_code(letter, value):
    return "%s%02d" % (letter, value)


def expand_declared(line, rel):
    """Išplėčia vienos REGISTRY-CODES eilutės tokenus į kodų aibę.

    Grąžina (codes: dict kodo→tokenas, errors: [str])."""
    pos = line.find(DECLARED_MARKER)
    if pos < 0:
        return {}, ["%s: nerasta deklaratyvi „%s“ eilutė" % (rel, DECLARED_MARKER)]
    tail = line[pos + len(DECLARED_MARKER):]
    codes, errors = {}, []
    for token in tail.split():
        m = RANGE_RE.match(token)
        am = A_RANGE_RE.match(token)
        if m and m.group(1) == m.group(3) and int(m.group(2)) <= int(m.group(4)):
            span = [msprintf_code(m.group(1), v) for v in range(int(m.group(2)), int(m.group(4)) + 1)]
        elif am and am.group(1) == am.group(3) and int(am.group(2)) <= int(am.group(4)):
            span = ["A%s.%02d" % (am.group(1), v) for v in range(int(am.group(2)), int(am.group(4)) + 1)]
        elif CODE_FULL_RE.match(token):
            span = [token]
        else:
            errors.append("%s: nesuprantamas diapazono tokenas „%s“" % (rel, token))
            continue
        for code in span:
            if code in codes:
                errors.append("%s: kodas „%s“ deklaruotas dukart (tokenas „%s“)" % (rel, code, token))
            else:
                codes[code] = token
    return codes, errors


def collect_registries(root):
    """Registro parse: deklaratyvi REGISTRY-CODES eilutė + literalų kryžminė patikra."""
    registries, config_errors = {}, []
    for ld, rel in REGISTRIES:
        path = root / rel
        if not path.is_file():
            config_errors.append("registro failas nerastas: " + str(path))
            continue
        declared, decl_errors = {}, []
        literal_codes, dups = {}, []
        for lineno, line in enumerate(read_text(path).splitlines(), 1):
            if DECLARED_MARKER in line:
                declared, decl_errors = expand_declared(line, rel + ":" + str(lineno))
                continue
            for literal in string_literals(strip_comment(line)):
                if CODE_FULL_RE.match(literal):
                    if literal in literal_codes:
                        dups.append((literal, lineno, literal_codes[literal]))
                    else:
                        literal_codes[literal] = lineno
        errors = list(decl_errors)
        if not declared and not decl_errors:
            errors.append("%s: deklaracija tuščia" % rel)
        for literal, lineno, first in dups:
            errors.append('%s:%d: kodas "%s" pasikartoja registre (pirmą kartą eilutėje %d)'
                          % (rel, lineno, literal, first))
        for literal in sorted(set(literal_codes) - set(declared)):
            errors.append("%s:%d: literalas „%s“ registre, bet neįtrauktas į deklaraciją"
                          % (rel, literal_codes[literal], literal))
        registries[ld] = {"rel": rel, "path": path, "codes": declared, "dups": dups,
                          "errors": errors}
    return registries, config_errors


def scan_references(root, exclude):
    """Visos [kodo] nuorodos .sci/.sce failuose po studentui/ (be registrų)."""
    refs = []
    for scan_dir in SCAN_DIRS:
        base = root / scan_dir
        if not base.is_dir():
            continue
        for path in sorted(base.rglob("*")):
            if path.suffix not in SCAN_SUFFIXES or not path.is_file():
                continue
            if path.resolve() in exclude:  # pačius registrų failus neskanuojam
                continue
            rel = path.relative_to(root).as_posix()
            for lineno, line in enumerate(read_text(path).splitlines(), 1):
                for match in REF_RE.finditer(line):
                    refs.append((rel, lineno, match.group(1)))
    return refs


def check(root):
    """Grąžina (exit_kodas, ataskaitos eilutės)."""
    lines = ["== Instrukcijų <-> registrų patikra (šaknis: " + str(root) + ") =="]
    registries, config_errors = collect_registries(root)
    if config_errors:
        lines.extend("KLAIDA: " + msg for msg in config_errors)
        lines.append("RESULT: konfigūracijos trūkumas (exit 2)")
        return 2, lines

    errors = []
    for reg in registries.values():
        errors.extend(reg["errors"])
        if not reg["codes"]:
            errors.append(reg["rel"] + ":0: registre nerasta nė vieno kodo")

    exclude = {reg["path"].resolve() for reg in registries.values()}
    refs = scan_references(root, exclude)
    known = set()
    for reg in registries.values():
        known.update(reg["codes"])

    bad = {}
    for rel, lineno, code in refs:
        if code not in known:
            bad.setdefault((rel, code), []).append(lineno)
    for (rel, code), linenos in sorted(bad.items()):
        extra = "" if len(linenos) == 1 else " (dar %d kart. tame faile)" % (len(linenos) - 1)
        errors.append("%s:%d: nuoroda [%s] nerasta jokiame registre%s"
                      % (rel, linenos[0], code, extra))

    # Statistika per LD: kiek kodų registre, kiek unikalių nuorodų, padengimas.
    ref_codes = {code for _, _, code in refs}
    for ld, reg in registries.items():
        total = len(reg["codes"])
        hit = len(ref_codes & set(reg["codes"]))
        pct = 100.0 * hit / total if total else 0.0
        lines.append("%s: registras %s — %d kodų; unikalių nuorodų tekstuose — %d; "
                     "padengimas %d/%d (%.1f%%)" % (ld, reg["rel"], total, hit, hit, total, pct))
    files = sorted({rel for rel, _, _ in refs})
    lines.append("Patikrinta failų: %d; nuorodų iš viso: %d; unikalių kodų: %d"
                 % (len(files), len(refs), len(ref_codes)))
    if errors:
        lines = lines[:1] + ["KLAIDA: " + e for e in errors] + lines[1:]
        lines.append("RESULT: rasta klaidų: %d (exit 1)" % len(errors))
        return 1, lines
    lines.append("RESULT: OK — visos nuorodos egzistuoja registruose (exit 0)")
    return 0, lines


def write(tmp, rel, text):
    path = tmp / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def fake_registry(codes):
    """Mini registras tomis pačiomis formomis kaip tikrieji (stulpelio vektorius + deklaracija)."""
    rows = ";".join('"%s"' % code for code in codes)
    declared = " ".join(sorted(codes))
    return ("// %s %s\nfunction codes=ld_all_codes()\n    codes=[%s]\nendfunction\n"
            % (DECLARED_MARKER, declared, rows))


def self_test():
    """Savitikra laikiname medyje: geras, blogas, dublis, literalas už deklaracijos, trūkstamas registras."""
    tmp = Path(tempfile.mkdtemp(prefix="check_instruction_registry_"))
    try:
        # 1) Geras atvejis: visos nuorodos galiojančios.
        write(tmp, "good/studentui/LD1/ld1_ids.sci", fake_registry(["T01", "B01", "E01"]))
        write(tmp, "good/studentui/LD2/ld2_ids.sci", fake_registry(["T01", "B01", "V01", "A03.01"]))
        write(tmp, "good/studentui/LD3/ld3_ids.sci", fake_registry(["T01", "B01", "W01"]))
        write(tmp, "good/studentui/LD2/ld2_note.sci",
              'mprintf("Pirmas žingsnis [T01], paskui [B01].\\n")\n')
        write(tmp, "good/studentui/LD1/ld1_note.sci", "// metodikos žingsnis [E01], žr. [A03.01]\n")
        good_code, good_lines = check(tmp / "good")

        # 2) Blogas atvejis: [V09] LD2 registre neegzistuoja → turi rasti.
        write(tmp, "good/studentui/extra.sci", "// bloga nuoroda [V09]\n")
        bad_code, bad_lines = check(tmp / "good")

        # 3) Dublis tame pačiame registre.
        write(tmp, "dup/studentui/LD1/ld1_ids.sci", fake_registry(["T01", "T01"]))
        write(tmp, "dup/studentui/LD2/ld2_ids.sci", fake_registry(["B01"]))
        write(tmp, "dup/studentui/LD3/ld3_ids.sci", fake_registry(["B01"]))
        dup_code, dup_lines = check(tmp / "dup")

        # 4) Literalas registre, bet neįtrauktas į deklaraciją.
        lit_reg = fake_registry(["T01", "T02"]).replace(
            DECLARED_MARKER + " T01 T02", DECLARED_MARKER + " T01")
        write(tmp, "lit/studentui/LD1/ld1_ids.sci", lit_reg)
        write(tmp, "lit/studentui/LD2/ld2_ids.sci", fake_registry(["B01"]))
        write(tmp, "lit/studentui/LD3/ld3_ids.sci", fake_registry(["B01"]))
        lit_code, lit_lines = check(tmp / "lit")

        # 5) Registro failo nėra → exit 2.
        write(tmp, "missing/studentui/LD2/ld2_ids.sci", fake_registry(["B01"]))
        miss_code, miss_lines = check(tmp / "missing")

        problems = []
        if good_code != 0:
            problems.append("geras atvejis turi grąžinti 0, grąžino %d: %s" % (good_code, good_lines))
        if bad_code != 1 or not any("[V09]" in line for line in bad_lines):
            problems.append("blogas atvejis turi grąžinti 1 ir paminėti [V09], grąžino %d: %s"
                            % (bad_code, bad_lines))
        if dup_code != 1 or not any("pasikartoja" in line for line in dup_lines):
            problems.append("dublis turi grąžinti 1, grąžino %d: %s" % (dup_code, dup_lines))
        if lit_code != 1 or not any("neįtrauktas" in line for line in lit_lines):
            problems.append("literalas už deklaracijos turi grąžinti 1, grąžino %d: %s"
                            % (lit_code, lit_lines))
        if miss_code != 2 or not any("nerastas" in line for line in miss_lines):
            problems.append("trūkstamas registras turi grąžinti 2, grąžino %d: %s"
                            % (miss_code, miss_lines))
        if problems:
            for problem in problems:
                print("SELF-TEST FAIL: " + problem)
            return 1
        print("SELF-TEST PASS: geras=0; blogas=1 (įvardintas [V09]); dublis=1; "
              "literalas už deklaracijos=1; trūkstamas registras=2")
        return 0
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def main():
    parser = argparse.ArgumentParser(
        description="Patikrina, kad visos [kodo] nuorodos .sci/.sce egzistuoja kodų registruose.")
    parser.add_argument("--root", default=str(Path(__file__).resolve().parents[1]),
                        help="repo šaknis (numatyta: katalogas virš scripto)")
    parser.add_argument("--self-test", action="store_true",
                        help="savikontrolė su laikinu medžiu (vietoj pytest)")
    args = parser.parse_args()
    if hasattr(sys.stdout, "reconfigure"):  # Windows konsolė be UTF-8
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    if args.self_test:
        return self_test()
    code, lines = check(Path(args.root))
    for line in lines:
        print(line)
    return code


if __name__ == "__main__":
    sys.exit(main())
