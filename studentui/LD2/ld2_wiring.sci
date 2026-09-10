// ============================================================================
// Laidų, lizdų ir topologijos logika
// ============================================================================

function req = ld2_required_main(phase)
    select phase
    case "RC" then
        req = ["GEN_H" "AM_H";
               "AM_L"  "R8_1";
               "R8_2"  "C2_1";
               "C2_2"  "GEN_L"];
    case "RL" then
        req = ["GEN_H" "AM_H";
               "AM_L"  "R9_1";
               "R9_2"  "L1_1";
               "L1_2"  "GEN_L"];
    case "RLC" then
        req = ["GEN_H" "AM_H";
               "AM_L"  "C4_1";
               "C4_2"  "L3_1";
               "L3_2"  "R13_1";
               "R13_2" "GEN_L"];
    else
        req = emptystr(0,2);
    end
endfunction

function allowed = ld2_allowed_pairs(step)
    phase = ld2_phase_for_step(step);
    allowed = ld2_required_main(phase);
    select step
    case 4 then
        allowed = [allowed;
                   "VM_H" "R8_M1"; "VM_L" "R8_M2";
                   "VM_H" "R8_M2"; "VM_L" "R8_M1";
                   "VM_H" "C2_M1"; "VM_L" "C2_M2";
                   "VM_H" "C2_M2"; "VM_L" "C2_M1";
                   "VM_H" "GEN_MH"; "VM_L" "GEN_ML";
                   "VM_H" "GEN_ML"; "VM_L" "GEN_MH"];
    case 7 then
        allowed = [allowed;
                   "VM_H" "R9_M1"; "VM_L" "R9_M2";
                   "VM_H" "R9_M2"; "VM_L" "R9_M1";
                   "VM_H" "L1_M1"; "VM_L" "L1_M2";
                   "VM_H" "L1_M2"; "VM_L" "L1_M1";
                   "VM_H" "GEN_MH"; "VM_L" "GEN_ML";
                   "VM_H" "GEN_ML"; "VM_L" "GEN_MH"];
    case 9 then
        allowed = [allowed;
                   "VM_H" "R13_M1"; "VM_L" "R13_M2";
                   "VM_H" "R13_M2"; "VM_L" "R13_M1"];
    case 10 then
        allowed = [allowed;
                   "VM_H" "L3_M1"; "VM_L" "L3_M2";
                   "VM_H" "L3_M2"; "VM_L" "L3_M1";
                   "VM_H" "C4_M1"; "VM_L" "C4_M2";
                   "VM_H" "C4_M2"; "VM_L" "C4_M1";
                   "VM_H" "LC_M1"; "VM_L" "LC_M2";
                   "VM_H" "LC_M2"; "VM_L" "LC_M1"];
    case 12 then
        allowed = [allowed;
                   "VM_H" "R13_M1"; "VM_L" "R13_M2";
                   "VM_H" "R13_M2"; "VM_L" "R13_M1"];
    case 11 then
        allowed = [allowed;
                   "VM_H" "R13_M1"; "VM_L" "R13_M2";
                   "VM_H" "R13_M2"; "VM_L" "R13_M1"];
    end
endfunction

function tf = ld2_pair_in_matrix(a, b, pairs)
    tf = %f;
    for k = 1:size(pairs,1)
        if ld2_pair(a,b,pairs(k,1),pairs(k,2)) then
            tf = %t;
            return;
        end
    end
endfunction

function [ok, missing] = ld2_validate_main(phase)
    c = ld2_get_phase_connections(phase);
    req = ld2_required_main(phase);
    missing = emptystr(0,2);
    for k = 1:size(req,1)
        if ~ld2_has_connection(c, req(k,1), req(k,2)) then
            missing = [missing; req(k,:)];
        end
    end
    ok = size(missing,1) == 0;
endfunction

function target = ld2_detect_voltage_target(phase)
    c = ld2_get_phase_connections(phase);
    target = "";
    if phase == "RC" then
        if (ld2_has_connection(c,"VM_H","R8_M1") & ld2_has_connection(c,"VM_L","R8_M2")) | ...
           (ld2_has_connection(c,"VM_H","R8_M2") & ld2_has_connection(c,"VM_L","R8_M1")) then
            target = "UR";
        elseif (ld2_has_connection(c,"VM_H","C2_M1") & ld2_has_connection(c,"VM_L","C2_M2")) | ...
               (ld2_has_connection(c,"VM_H","C2_M2") & ld2_has_connection(c,"VM_L","C2_M1")) then
            target = "UC";
        elseif (ld2_has_connection(c,"VM_H","GEN_MH") & ld2_has_connection(c,"VM_L","GEN_ML")) | ...
               (ld2_has_connection(c,"VM_H","GEN_ML") & ld2_has_connection(c,"VM_L","GEN_MH")) then
            target = "UE";
        end
    elseif phase == "RL" then
        if (ld2_has_connection(c,"VM_H","R9_M1") & ld2_has_connection(c,"VM_L","R9_M2")) | ...
           (ld2_has_connection(c,"VM_H","R9_M2") & ld2_has_connection(c,"VM_L","R9_M1")) then
            target = "UR";
        elseif (ld2_has_connection(c,"VM_H","L1_M1") & ld2_has_connection(c,"VM_L","L1_M2")) | ...
               (ld2_has_connection(c,"VM_H","L1_M2") & ld2_has_connection(c,"VM_L","L1_M1")) then
            target = "UL";
        elseif (ld2_has_connection(c,"VM_H","GEN_MH") & ld2_has_connection(c,"VM_L","GEN_ML")) | ...
               (ld2_has_connection(c,"VM_H","GEN_ML") & ld2_has_connection(c,"VM_L","GEN_MH")) then
            target = "UE";
        end
    elseif phase == "RLC" then
        if (ld2_has_connection(c,"VM_H","R13_M1") & ld2_has_connection(c,"VM_L","R13_M2")) | ...
           (ld2_has_connection(c,"VM_H","R13_M2") & ld2_has_connection(c,"VM_L","R13_M1")) then
            target = "UR";
        elseif (ld2_has_connection(c,"VM_H","L3_M1") & ld2_has_connection(c,"VM_L","L3_M2")) | ...
               (ld2_has_connection(c,"VM_H","L3_M2") & ld2_has_connection(c,"VM_L","L3_M1")) then
            target = "UL";
        elseif (ld2_has_connection(c,"VM_H","C4_M1") & ld2_has_connection(c,"VM_L","C4_M2")) | ...
               (ld2_has_connection(c,"VM_H","C4_M2") & ld2_has_connection(c,"VM_L","C4_M1")) then
            target = "UC";
        elseif (ld2_has_connection(c,"VM_H","LC_M1") & ld2_has_connection(c,"VM_L","LC_M2")) | ...
               (ld2_has_connection(c,"VM_H","LC_M2") & ld2_has_connection(c,"VM_L","LC_M1")) then
            target = "ULC";
        end
    end
endfunction

function [ok, problem, fixes] = ld2_validate_voltage_probes(phase, expected)
    target = ld2_detect_voltage_target(phase);
    ok = %f;
    problem = "";
    fixes = emptystr(0,1);
    if target == "" then
        problem = "Voltmetro zondai neprijungti prie vieno pilno matavimo taikinio.";
        select expected
        case "UR_RC" then fixes = ["V~ prijunkite prie dviejų violetinių R8 matavimo lizdų."; "Vienas zondas turi būti kiekvienoje R8 pusėje."];
        case "UC_RC" then fixes = ["V~ prijunkite prie dviejų violetinių C2 matavimo lizdų."; "Vienas zondas turi būti kiekvienoje C2 pusėje."];
        case "UE_RC" then fixes = ["V~ prijunkite lygiagrečiai generatoriaus ~ ir 0 V lizdams."];
        case "UR_RL" then fixes = ["V~ prijunkite prie dviejų violetinių R9 matavimo lizdų."];
        case "UL_RL" then fixes = ["V~ prijunkite prie dviejų violetinių L1 matavimo lizdų."];
        case "UE_RL" then fixes = ["V~ prijunkite lygiagrečiai generatoriaus ~ ir 0 V lizdams."];
        case "UR_RLC" then fixes = ["V~ prijunkite prie dviejų violetinių R13 matavimo lizdų."];
        case "UL_RLC" then fixes = ["V~ prijunkite prie dviejų violetinių L3 matavimo lizdų."];
        case "UC_RLC" then fixes = ["V~ prijunkite prie dviejų violetinių C4 matavimo lizdų."];
        case "ULC_RLC" then fixes = ["V~ prijunkite prie L3–C4 poros kraštinių LC matavimo lizdų."];
        end
        return;
    end

    expected_target = ld2_target_code(expected);
    if target <> expected_target then
        problem = "Voltmetras prijungtas prie " + target + ", o šiame veiksme reikia " + expected_target + ".";
        fixes = ["Paspauskite NUIMTI ZONDUS."; ...
                 "Tada prijunkite abu zondus prie instrukcijoje nurodyto elemento kraštų."];
        return;
    end
    ok = %t;
endfunction

function [ok, msg, fix] = ld2_can_add_pair(step, a, b)
    phase = ld2_phase_for_step(step);
    c = ld2_get_phase_connections(phase);
    allowed = ld2_allowed_pairs(step);
    ok = %f; msg = ""; fix = "";

    if a == b then
        msg = "Pasirinktas tas pats lizdas du kartus.";
        fix = "Pasirinkite pirmą lizdą, tada kitame komponente pasirinkite antrą lizdą.";
        return;
    end

    if ~ld2_pair_in_matrix(a,b,allowed) then
        msg = "Šių dviejų lizdų jungtis šiame etape nereikalinga.";
        [valid, missing] = ld2_validate_main(phase);
        if ~valid then
            fix = "Kitas reikalingas laidas: " + ld2_terminal_name(missing(1,1)) + ...
                  " → " + ld2_terminal_name(missing(1,2)) + ".";
        else
            fix = "Vadovaukitės dešinėje nurodytu voltmetro matavimo taikiniu arba atverkite PAVYZDĮ.";
        end
        return;
    end

    if ld2_has_connection(c,a,b) then
        msg = "Toks laidas jau prijungtas.";
        fix = "Jo nekartokite. Pasirinkite kitą dar nesujungtą porą.";
        return;
    end

    if ld2_terminal_used(c,a) then
        msg = ld2_terminal_name(a) + " jau užimtas kitu laidu.";
        fix = "Paspauskite ATŠAUKTI LAIDĄ arba NUIMTI ZONDUS, tada prijunkite iš naujo.";
        return;
    end
    if ld2_terminal_used(c,b) then
        msg = ld2_terminal_name(b) + " jau užimtas kitu laidu.";
        fix = "Paspauskite ATŠAUKTI LAIDĄ arba NUIMTI ZONDUS, tada prijunkite iš naujo.";
        return;
    end
    ok = %t;
endfunction

function c = ld2_add_pair(c, a, b)
    c = [c; a b];
endfunction

function c = ld2_solution_connections(step)
    phase = ld2_phase_for_step(step);
    c = ld2_required_main(phase);
    select step
    case 4 then c = [c; "VM_H" "R8_M1"; "VM_L" "R8_M2"];
    case 7 then c = [c; "VM_H" "R9_M1"; "VM_L" "R9_M2"];
    case 9 then c = [c; "VM_H" "R13_M1"; "VM_L" "R13_M2"];
    case 10 then c = [c; "VM_H" "L3_M1"; "VM_L" "L3_M2"];
    case 12 then c = [c; "VM_H" "R13_M1"; "VM_L" "R13_M2"];
    case 11 then c = [c; "VM_H" "R13_M1"; "VM_L" "R13_M2"];
    end
endfunction

function target=ld2_target_code(expected)
    select expected
    case "UR_RC" then target="UR";
    case "UC_RC" then target="UC";
    case "UE_RC" then target="UE";
    case "UR_RL" then target="UR";
    case "UL_RL" then target="UL";
    case "UE_RL" then target="UE";
    case "UR_RLC" then target="UR";
    case "UL_RLC" then target="UL";
    case "UC_RLC" then target="UC";
    case "ULC_RLC" then target="ULC";
    else target=expected;
    end
endfunction

function pair=ld2_probe_pair(phase,target)
    prefix="";
    if target=="UE" then pair=["GEN_MH" "GEN_ML"]; return; end
    if phase=="RC" then
        if target=="UR" then prefix="R8"; end
        if target=="UC" then prefix="C2"; end
    elseif phase=="RL" then
        if target=="UR" then prefix="R9"; end
        if target=="UL" then prefix="L1"; end
    elseif phase=="RLC" then
        if target=="UR" then prefix="R13"; end
        if target=="UL" then prefix="L3"; end
        if target=="UC" then prefix="C4"; end
        if target=="ULC" then prefix="LC"; end
    end
    if prefix=="" then pair=emptystr(0,2); else pair=[prefix+"_M1" prefix+"_M2"]; end
endfunction
