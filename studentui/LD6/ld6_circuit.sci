// ============================================================================
// LD6 grandinės modelis: DVIEJŲ ŠALTINIŲ jungimas. Trys režimai:
// mode=1: tik E1; mode=2: E1+E2 (sutampantys); mode=3: E1−E2 (priešinieji).
// ============================================================================

function w = ld6_canonical_wires(mode)
    select mode
    case 1 then w = ["E1_P" "K1";"K2" "A_P";"A_N" "R_A";"R_B" "E1_N";"V_P" "R_A";"V_N" "R_B"];
    case 2 then w = ["E1_P" "K1";"K2" "A_P";"A_N" "R_A";"R_B" "E2_N";"E2_P" "E1_N";"V_P" "R_A";"V_N" "R_B"];
    else w = ["E1_P" "K1";"K2" "A_P";"A_N" "R_A";"R_B" "E2_P";"E2_N" "E1_N";"V_P" "R_A";"V_N" "R_B"];
    end
endfunction

function emf = ld6_mode_emf()
    global LD6;
    select LD6.wireMode
    case 1 then emf = LD6.cfg.E1;
    case 2 then emf = LD6.cfg.E1 + LD6.cfg.E2;
    else emf = LD6.cfg.E1 - LD6.cfg.E2;
    end
endfunction

function [u, i, ok, msg] = ld6_measure_values()
    global LD6;
    u = %nan; i = %nan; ok = %f; msg = "";
    if ~LD6.powerOn then msg = "Maitinimas išjungtas: [B01]."; return; end
    if ~LD6.switchOn then msg = "Jungiklis atidarytas: [B02]."; return; end
    if ~isfield(LD6, "wires") | LD6.wires == [] then msg = "Grandinė nesujungta: [B04]."; return; end
    [wok, wwhy] = ld6_wiring_valid(LD6.wires);
    if ~wok then msg = wwhy; return; end
    u = ld6_mode_emf();
    i = ld6_mode_emf() / LD6.cfg.R * 1000;
    ok = %t;
endfunction

function [ok, reason] = ld6_wiring_valid(wires)
    global LD6;
    ok = %f; reason = "";
    m = LD6.wireMode;
    canon = ld6_canonical_wires(m);
    if ~isfield(LD6, "wires") | LD6.wires == [] then
        reason = "Grandinė nesujungta: [B04] KAIP SUJUNGTI."; return;
    end
    if size(LD6.wires, 1) > size(canon, 1) then
        reason = "Per daug laidų (riba " + string(size(canon,1)) + ")."; return;
    end
    for k = 1:size(canon, 1)
        rasta = %f;
        for mm = 1:size(LD6.wires, 1)
            par = [LD6.wires(mm,1) LD6.wires(mm,2)];
            if and(par == canon(k,:)) | and(par == canon(k, [2 1])) then rasta = %t; end
        end
        if ~rasta then
            reason = "Trūksta " + canon(k,1) + "–" + canon(k,2) + " (" + ...
                     ld6_terminal_code(canon(k,1)) + "–" + ld6_terminal_code(canon(k,2)) + ").";
            return;
        end
    end
    ok = %t;
endfunction

function ld6_init_state()
    global LD6;
    LD6.step = 1;
    LD6.done = [%f %f %f %f %f %f];
    LD6.skipped = [%f %f %f %f %f %f];
    LD6.powerOn = %f;
    LD6.switchOn = %f;
    LD6.wireMode = 1;
    LD6.wires = [];
    LD6.journal = [];      // [U, I_mA, mode]
    LD6.answers = emptystr(6, 8);
    LD6.demoMode = %f;
    LD6.lastMeasurement = %nan;
    LD6.pending = "";
endfunction

function expected = ld6_expected_answers()
    global LD6;
    expected = emptystr(6, 8);
    cfg = LD6.cfg;
    expected(2,1) = msprintf("%.10g", cfg.E1 / cfg.R * 1000);       // A02.01 I1, mA
    expected(4,1) = msprintf("%.10g", cfg.E1 + cfg.E2);              // A04.01 U_ser
    expected(4,2) = msprintf("%.10g", (cfg.E1 + cfg.E2) / cfg.R * 1000); // A04.02 I_ser
    expected(4,3) = msprintf("%.10g", cfg.E1 - cfg.E2);              // A04.03 U_pries
    expected(4,4) = msprintf("%.10g", (cfg.E1 - cfg.E2) / cfg.R * 1000); // A04.04 I_pries
    expected(6,1) = "1";
    expected(6,2) = "1";
endfunction

function rows = ld6_journal_rows(tag)
    global LD6;
    rows = [];
    if ~isfield(LD6, "journal") | LD6.journal == [] then return; end
    for m = 1:size(LD6.journal, 1)
        if LD6.journal(m, 3) == tag then rows($+1, :) = LD6.journal(m, 1:2); end
    end
endfunction
