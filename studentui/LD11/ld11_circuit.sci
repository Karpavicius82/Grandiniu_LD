// ============================================================================
// LD11 grandinės modelis: ritė (R, L nuosekliai) su paraleliniu kompensuo-
// jančiu kondensatoriumi Ck. Fizika — ld_ac kind 5 (C = 0 – be kondensatoriaus):
// [XL, Z_RL, cosφ0, I bendra, I_RL, P, Q, S, φ°, IC]. Žurnalas: [U V, I mA,
// režimas 1–2, P mW, režimas]; režimas 1 – be Ck, 2 – su Ck. f = 50 Hz.
// ============================================================================

function wires = ld11_canonical_wires(mode)
    wires = emptystr(0, 2);
    if ~ld11_valid_index(mode, 2) then return; end
    base = ["GEN_P" "K1";"K2" "A_P";"A_N" "RL_A";"RL_B" "GEN_N"];
    select mode
    case 1 then wires = base;
    case 2 then wires = [base;"RL_A" "C_A";"C_B" "RL_B"];
    end
endfunction

function mode = ld11_stage_mode(step)
    mapping = [1 1 1 2 2 2]; mode = mapping(step);
endfunction

function editable = ld11_wiring_editable()
    global LD11;
    editable = ~LD11.demoMode & or(LD11.step == [1 4]) & LD11.wireMode == ld11_stage_mode(LD11.step);
endfunction

function [ok, reason] = ld11_wiring_valid(wires)
    global LD11;
    ok = %f; reason = "Sujunkite grandinę pagal Pagalba → Kaip sujungti.";
    if ~ld11_valid_index(LD11.wireMode, 2) then return; end
    canonical = ld11_canonical_wires(LD11.wireMode);
    if wires == [] then return; end
    if type(wires) <> 10 | size(wires, 2) <> 2 then reason = "Netinkami sujungimo duomenys."; return; end
    if size(wires, 1) > size(canonical, 1) then reason = "Per daug laidų."; return; end
    // Previous reports/drafts used the same return node at GEN_N.
    if LD11.wireMode==2 then
        for k=1:size(wires,1)
            if and(wires(k,:)==["C_B" "GEN_N"]) | and(wires(k,:)==["GEN_N" "C_B"]) then wires(k,:)=["C_B" "RL_B"]; end
        end
    end
    for index = 1:size(canonical, 1)
        present = %f;
        for row = 1:size(wires, 1)
            if and(wires(row,:) == canonical(index,:)) | and(wires(row,:) == canonical(index,[2 1])) then present = %t; end
        end
        if ~present then
            reason = "Trūksta laido ["+ld11_terminal_code(canonical(index,1))+"]–["+ld11_terminal_code(canonical(index,2))+"].";
            return;
        end
    end
    ok = %t; reason = "";
endfunction

function [u, i, ok, message, p] = ld11_measure_values()
    // U V, I mA, ok, message, P mW su esamu režimu (1 be Ck, 2 su Ck).
    global LD11;
    u = %nan; i = %nan; ok = %f; message = ""; p = %nan;
    if ~LD11.powerOn then message = "Įjunkite generatorių [B01]."; return; end
    if ~LD11.switchOn then message = "Uždarykite jungiklį [B02]."; return; end
    [valid, message] = ld11_wiring_valid(LD11.wires);
    if ~valid then return; end
    bench_core_require(); cfg = LD11.cfg;
    ck = 0;
    if LD11.wireMode == 2 then ck = cfg.Ck; end
    v = bench_cpp_ac(5, cfg.E, 50, cfg.R, cfg.L, ck);
    u = cfg.E; i = v(4)*1000; p = v(6)*1000; ok = %t;
endfunction

function ld11_init_state()
    global LD11;
    LD11.assessment=%t; LD11.practice_used=%f;
    LD11.step = 1; LD11.done = zeros(1, 6) == 1; LD11.skipped = zeros(1, 6) == 1;
    LD11.powerOn = %f; LD11.switchOn = %f; LD11.wireMode = 1;
    LD11.wires = emptystr(0, 2); LD11.journal = [];
    LD11.wires_by_mode = list(); LD11.report_wires = list();
    for index = 1:2
        LD11.wires_by_mode(index) = emptystr(0, 2); LD11.report_wires(index) = emptystr(0, 2);
    end
    LD11.answers = emptystr(6, 8); LD11.demoMode = %f; LD11.lastMeasurement = %nan; LD11.pending = "";
endfunction

function expected = ld11_expected_answers()
    global LD11;
    cfg = LD11.cfg;
    expected = %nan * ones(6, 8);
    before=bench_cpp_ac(5,cfg.E,50,cfg.R,cfg.L,0);
    after=bench_cpp_ac(5,cfg.E,50,cfg.R,cfg.L,cfg.Ck);
    expected(1,1)=before(3);
    expected(2,1:3)=[before(8)*1000,abs(before(7))*1000,before(6)/before(8)];
    expected(3,1)=cfg.Ck*1e6;
    expected(5,1:4)=[after(8)*1000,abs(after(7))*1000,after(6)/after(8),(before(8)-after(8))*1000];
    expected(6, 1:3) = [1 1 1];
endfunction

function rows = ld11_journal_rows(tag)
    global LD11;
    rows = [];
    if LD11.journal == [] then return; end
    indices = find(LD11.journal(:, 3) == tag);
    if indices <> [] then rows = LD11.journal(indices, :); end
endfunction
