// ============================================================================
// Bendros LD2 funkcijos
// ============================================================================

function s=ld2_num(x,digits)
    digits=max([0 min([8 round(digits)])]);
    s=msprintf("%."+string(digits)+"f",x);
endfunction

function s = ld2_value_or_dash(x, unit)
    if isnan(x) then
        s = "—";
    else
        s = ld2_num(x, 3) + " " + unit;
    end
endfunction

function v = ld2_safe_number(txt)
    v=bench_safe_number(txt);
endfunction

function ld2_set_status(msg, kind)
    global LD2;
    LD2.state.status_text=msg;
    if isfield(LD2.ui,"headless") then
        if LD2.ui.headless then return; end
    end
    if ~isfield(LD2.ui, "status") then return; end
    LD2.ui.status.string = msg;
    LD2.ui.status.tooltipstring = msg;
    select kind
    case "ok" then
        LD2.ui.status.backgroundcolor = [0.84 0.96 0.84];
        LD2.ui.status.foregroundcolor = [0.05 0.35 0.10];
    case "warn" then
        LD2.ui.status.backgroundcolor = [1.00 0.95 0.72];
        LD2.ui.status.foregroundcolor = [0.45 0.25 0.00];
    case "error" then
        LD2.ui.status.backgroundcolor = [1.00 0.84 0.84];
        LD2.ui.status.foregroundcolor = [0.55 0.05 0.05];
    else
        LD2.ui.status.backgroundcolor = [0.88 0.93 0.98];
        LD2.ui.status.foregroundcolor = [0.05 0.18 0.32];
    end
endfunction

function ld2_show_error(problem, fixes)
    global LD2;
    LD2.state.last_error=problem;
    fixes=matrix(fixes,-1,1);
    LD2.state.last_fix=strcat(fixes," ");
    if isfield(LD2.ui,"test_no_dialogs") then
        if LD2.ui.test_no_dialogs then return; end
    end
    if isfield(LD2.ui,"headless") then
        if LD2.ui.headless then return; end
    end
    ld2_set_status(problem+" "+strcat(fixes," "),"error");
    messagebox(["KLAIDA: "+problem;"";"KAIP PATAISYTI:";fixes], ...
        "LD2 – taisymo nurodymas","error","modal");
endfunction

function ld2_show_info(title, lines)
    global LD2;
    if isfield(LD2.ui,"headless") then
        if LD2.ui.headless then return; end
    end
    messagebox(matrix(lines,-1,1),title,"info","modal");
endfunction

function phase = ld2_phase_for_step(step)
    if step >= 2 & step <= 4 then
        phase = "RC";
    elseif step >= 5 & step <= 7 then
        phase = "RL";
    elseif step >= 8 & step <= 12 then
        phase = "RLC";
    else
        phase = "OVERVIEW";
    end
endfunction

function c = ld2_get_phase_connections(phase)
    global LD2;
    select phase
    case "RC" then
        c = LD2.state.rc_connections;
    case "RL" then
        c = LD2.state.rl_connections;
    case "RLC" then
        c = LD2.state.rlc_connections;
    else
        c = emptystr(0,2);
    end
endfunction

function ld2_set_phase_connections(phase, c)
    global LD2;
    select phase
    case "RC" then
        LD2.state.rc_connections = c;
    case "RL" then
        LD2.state.rl_connections = c;
    case "RLC" then
        LD2.state.rlc_connections = c;
    end
endfunction

function tf = ld2_pair(a, b, x, y)
    tf = (a == x & b == y) | (a == y & b == x);
endfunction

function tf = ld2_has_connection(c, a, b)
    tf = %f;
    for k = 1:size(c,1)
        if ld2_pair(c(k,1), c(k,2), a, b) then
            tf = %t;
            return;
        end
    end
endfunction

function tf = ld2_terminal_used(c, id)
    tf = %f;
    for k = 1:size(c,1)
        if c(k,1) == id | c(k,2) == id then
            tf = %t;
            return;
        end
    end
endfunction

function c = ld2_remove_terminal_connections(c, ids)
    keep = [];
    for k = 1:size(c,1)
        remove = %f;
        for q = 1:size(ids, "*")
            if c(k,1) == ids(q) | c(k,2) == ids(q) then
                remove = %t;
            end
        end
        if ~remove then keep($+1) = k; end
    end
    if size(keep, "*") == 0 then
        c = emptystr(0,2);
    else
        c = c(keep,:);
    end
endfunction

function s = ld2_terminal_name(id)
    select id
    case "GEN_H" then s = "generatoriaus ~ išėjimas";
    case "GEN_L" then s = "generatoriaus 0 V grįžimas";
    case "GEN_MH" then s = "generatoriaus ~ matavimo lizdas";
    case "GEN_ML" then s = "generatoriaus 0 V matavimo lizdas";
    case "AM_H" then s = "ampermetro A~ įėjimas";
    case "AM_L" then s = "ampermetro COM išėjimas";
    case "VM_H" then s = "voltmetro V~ įėjimas";
    case "VM_L" then s = "voltmetro COM";
    case "R8_1" then s = "R8 kairysis pagrindinis lizdas";
    case "R8_2" then s = "R8 dešinysis pagrindinis lizdas";
    case "R8_M1" then s = "R8 kairysis matavimo lizdas";
    case "R8_M2" then s = "R8 dešinysis matavimo lizdas";
    case "C2_1" then s = "C2 kairysis pagrindinis lizdas";
    case "C2_2" then s = "C2 dešinysis pagrindinis lizdas";
    case "C2_M1" then s = "C2 kairysis matavimo lizdas";
    case "C2_M2" then s = "C2 dešinysis matavimo lizdas";
    case "R9_1" then s = "R9 kairysis pagrindinis lizdas";
    case "R9_2" then s = "R9 dešinysis pagrindinis lizdas";
    case "R9_M1" then s = "R9 kairysis matavimo lizdas";
    case "R9_M2" then s = "R9 dešinysis matavimo lizdas";
    case "L1_1" then s = "L1 kairysis pagrindinis lizdas";
    case "L1_2" then s = "L1 dešinysis pagrindinis lizdas";
    case "L1_M1" then s = "L1 kairysis matavimo lizdas";
    case "L1_M2" then s = "L1 dešinysis matavimo lizdas";
    case "C4_1" then s = "C4 kairysis pagrindinis lizdas";
    case "C4_2" then s = "C4 dešinysis pagrindinis lizdas";
    case "C4_M1" then s = "C4 kairysis matavimo lizdas";
    case "C4_M2" then s = "C4 dešinysis matavimo lizdas";
    case "L3_1" then s = "L3 kairysis pagrindinis lizdas";
    case "L3_2" then s = "L3 dešinysis pagrindinis lizdas";
    case "L3_M1" then s = "L3 kairysis matavimo lizdas";
    case "L3_M2" then s = "L3 dešinysis matavimo lizdas";
    case "R13_1" then s = "R13 kairysis pagrindinis lizdas";
    case "R13_2" then s = "R13 dešinysis pagrindinis lizdas";
    case "R13_M1" then s = "R13 kairysis matavimo lizdas";
    case "R13_M2" then s = "R13 dešinysis matavimo lizdas";
    case "LC_M1" then s = "L3–C4 poros kairysis matavimo lizdas";
    case "LC_M2" then s = "L3–C4 poros dešinysis matavimo lizdas";
    else s = id;
    end
endfunction

function lines = ld2_connection_list_text(req)
    lines = emptystr(size(req,1),1);
    for k = 1:size(req,1)
        lines(k) = msprintf("%d. %s  →  %s", k, ...
            ld2_terminal_name(req(k,1)), ld2_terminal_name(req(k,2)));
    end
endfunction

function txt = ld2_step_title(step)
    titles = [ ...
        "1. Darbo sandara ir parametrai"; ...
        "2. RC grandinės sujungimas"; ...
        "3. RC teoriniai skaičiavimai"; ...
        "4. RC matavimai ir fazoriai"; ...
        "5. RL grandinės sujungimas"; ...
        "6. RL teoriniai skaičiavimai"; ...
        "7. RL matavimai ir fazoriai"; ...
        "8. RLC rezonanso grandinės sujungimas"; ...
        "9. Rezonansinio dažnio paieška"; ...
        "10. Įtampų rezonansas: UL, UC ir ULC"; ...
        "11. -3 dB dažniai, juostos plotis ir Q"; ...
        "12. Rezonanso kreivė ir rezultatų suvestinė"];
    txt = titles(step);
endfunction

function lines = ld2_instruction_lines(step)
    global LD2;
    select step
    case 1 then
        lines = [ ...
          "Patikrinkite naudojamus R, L, C, U ir f parametrus."; ...
          "Jei jūsų KL-13001 modulio vertės kitokios, spauskite PARAMETRAI."; ...
          "Ši laboratorija naudoja teisingas kompleksinių dydžių formules."; ...
          "Kiekviename etape galima atverti pilnai atliktą PAVYZDĮ."; ...
          "Dėstytojo režimu galima iš karto pereiti į bet kurį etapą."];
    case 2 then
        lines = [ ...
          "Sujunkite nuoseklią RC grandinę, kai generatorius IŠJUNGTAS."; ...
          "Spauskite du mėlynus lizdus – tarp jų atsiras vienas laidas."; ...
          "A~ ampermetras turi būti nuosekliai bendrame grandinės laide."; ...
          "Baigę spauskite TIKRINTI SUJUNGIMĄ."; ...
          "Jei kyla neaiškumų, PAVYZDYS parodys visus 4 laidus."];
    case 3 then
        lines = [ ...
          "Apskaičiuokite XC, |Z|, I, UR, UC, P ir fazės kampą."; ...
          "Naudokite f, R8 ir C2 reikšmes, rodomas stende."; ...
          "Įtampų modulių nesudėkite aritmetiškai: E = √(UR²+UC²)."; ...
          "Srovė RC grandinėje pirmauja šaltinio įtampą."; ...
          "Atsakymus įrašykite nurodytais vienetais."];
    case 4 then
        lines = [ ...
          "Įjunkite generatorių ir pirmiausia išmatuokite bendrą srovę."; ...
          "Tada V~ zondais paeiliui išmatuokite UR8, UC2 ir šaltinio U."; ...
          "Programa pati atpažins, prie kurio elemento prijungti zondai."; ...
          "Po kiekvieno matavimo senus zondus nuimkite mygtuku."; ...
          "Fazorių ir oscilogramų langai atidaromi atskirai."];
    case 5 then
        lines = [ ...
          "Sujunkite nuoseklią RL grandinę, kai generatorius IŠJUNGTAS."; ...
          "A~ ampermetras jungiamas nuosekliai, R9 ir L1 – nuosekliai."; ...
          "Spauskite du mėlynus lizdus kiekvienam reikalingam laidui."; ...
          "Baigę spauskite TIKRINTI SUJUNGIMĄ."; ...
          "PAVYZDYS rodo pilnai sujungtą ir veikiančią schemą."];
    case 6 then
        lines = [ ...
          "Apskaičiuokite XL, |Z|, I, UR, UL, P ir fazės kampą."; ...
          "Naudokite f, R9 ir L1 reikšmes, rodomas stende."; ...
          "Įtampų moduliams galioja E = √(UR²+UL²)."; ...
          "Srovė RL grandinėje atsilieka nuo šaltinio įtampos."; ...
          "Atsakymus įrašykite nurodytais vienetais."];
    case 7 then
        lines = [ ...
          "Įjunkite generatorių ir išmatuokite bendrą srovę."; ...
          "V~ zondais paeiliui išmatuokite UR9, UL1 ir šaltinio U."; ...
          "Po kiekvieno matavimo paspauskite NUIMTI ZONDUS."; ...
          "Apskaičiuokite E iš fazorių ir I iš UR/R9."; ...
          "Atverkite fazorių bei oscilogramų langus palyginimui."];
    case 8 then
        lines = [ ...
          "Sujunkite C4, L3 ir R13 nuoseklią rezonansinę grandinę."; ...
          "Generatorius turi būti IŠJUNGTAS, A~ ampermetras – nuosekliai."; ...
          "Reikalingi 5 aiškiai nurodyti laidai."; ...
          "Baigę spauskite TIKRINTI SUJUNGIMĄ."; ...
          "PAVYZDYS rodo pilną grandinę ir kiekvieno laido paskirtį."];
    case 9 then
        lines = [ ...
          "V → R13 M1; COM → R13 M2. Įjunkite generatorių."; ...
          "Keiskite f: MATUOTI U → ĮRAŠYTI TAŠKĄ."; ...
          "Suraskite maksimumą; turėkite taškų iš abiejų jo pusių."; ...
          "Periodą T pažiūrėkite oscilogramoje; f = 1000/T, kai T yra ms."; ...
          "Įveskite teorinį fr, matuotą fr, periodą ir UR13 maksimumą."];
    case 10 then
        lines = [ ...
          "Ieškokite UL, UC maksimumų ir ULC minimumo atskirai."; ...
          "UL: L3 M1–M2; UC: C4 M1–M2; ULC: LC1–LC2."; ...
          "Kiekvienu atveju: keisti f → MATUOTI U → ĮRAŠYTI TAŠKĄ."; ...
          "Reikia bent 3 taškų kiekvienam taikiniui, abipus ekstremumo."; ...
          "Geriausi rodmenys ir jų dažniai lieka lentelėje virš schemos."; ...
          "Į laukus nurašykite lentelės reikšmes, ne vien teorinį fr."];
    case 11 then
        lines = [ ...
          "Pusės galios taškai nustatomi pagal UR13 = UR,max/√2."; ...
          "Tai teisingas nuoseklios RLC grandinės -3 dB kriterijus."; ...
          "Raskite apatinį f1 ir viršutinį f2 dažnius."; ...
          "Apskaičiuokite BW=f2−f1 ir Q=fr/BW."; ...
          "PAVYZDYS parodo ir analitinį, ir matavimo variantą."];
    case 12 then
        lines = [ ...
          "V → R13 M1; COM → R13 M2. Įjunkite generatorių."; ...
          "Spauskite SKENUOTI 0–10 kHz; lentelė lieka virš schemos."; ...
          "1–10 kHz taškai gaunami per tą patį MATUOTI U veiksmą."; ...
          "0 Hz yra atskirai pažymėta teorinė riba, ne AC matavimas."; ...
          "GRAFIKAS braižo būtent lentelės taškus. CSV išsaugo matavimų kilmę."; ...
          "IŠSAUGOTI išlaiko visą jūsų darbą kitam paleidimui."];
    end
endfunction
