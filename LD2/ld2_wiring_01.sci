// ============================================================================
// Laidų, lizdų ir topologijos logika
// ============================================================================

function req = ld2_required_main(phase)
    select phase
    case "RC" then
        req = ["GEN_H" "AM_H";"AM_L" "R8_1";"R8_2" "C2_1";"C2_2" "GEN_L"];
    case "RL" then
        req = ["GEN_H" "AM_H";"AM_L" "R9_1";"R9_2" "L1_1";"L1_2" "GEN_L"];
    case "RLC" then
        req = ["GEN_H" "AM_H";"AM_L" "C4_1";"C4_2" "L3_1";"L3_2" "R13_1";"R13_2" "GEN_L"];
    else
        req = emptystr(0,2);
    end
endfunction

function allowed = ld2_allowed_pairs(step)
    phase = ld2_phase_for_step(step);
    allowed = ld2_required_main(phase);
    select step
    case 4 then
        allowed = [allowed;"VM_H" "R8_M1"; "VM_L" "R8_M2";"VM_H" "R8_M2"; "VM_L" "R8_M1";"VM_H" "C2_M1"; "VM_L" "C2_M2";"VM_H" "C2_M2"; "VM_L" "C2_M1";"VM_H" "GEN_MH"; "VM_L" "GEN_ML";"VM_H" "GEN_ML"; "VM_L" "GEN_MH"];
    case 7 then
        allowed = [allowed;"VM_H" "R9_M1"; "VM_L" "R9_M2";"VM_H" "R9_M2"; "VM_L" "R9_M1";"VM_H" "L1_M1"; "VM_L" "L1_M2";"VM_H" "L1_M2"; "VM_L" "L1_M1";"VM_H" "GEN_MH"; "VM_L" "GEN_ML";"VM_H" "GEN_ML"; "VM_L" "GEN_MH"];
    case 9 then
        allowed = [allowed;"VM_H" "R13_M1"; "VM_L" "R13_M2";"VM_H" "R13_M2"; "VM_L" "R13_M1"];
    case 10 then
        allowed = [allowed;"VM_H" "L3_M1"; "VM_L" "L3_M2";"VM_H" "L3_M2"; "VM_L" "L3_M1";"VM_H" "C4_M1"; "VM_L" "C4_M2";"VM_H" "C4_M2"; "VM_L" "C4_M1";"VM_H" "LC_M1"; "VM_L" "LC_M2";"VM_H" "LC_M2"; "VM_L" "LC_M1"];
    case 12 then
        allowed = [allowed;"VM_H" "R13_M1"; "VM_L" "R13_M2";"VM_H" "R13_M2"; "VM_L" "R13_M1"];
    case 11 then
        allowed = [allowed;"VM_H" "R13_M1"; "VM_L" "R13_M2";"VM_H" "R13_M2"; "VM_L" "R13_M1"];
    end
endfunction

function tf = ld2_pair_in_matrix(a, b, pairs)
    tf = %f;
    for k = 1:size(pairs,1)
        if ld2_pair(a,b,pairs(k,1),pairs(k,2)) then tf = %t; return; end
    end
endfunction

function [ok, missing] = ld2_validate_main(phase)
    c = ld2_get_phase_connections(phase);
    req = ld2_required_main(phase);
    missing = emptystr(0,2);
    for k = 1:size(req,1)
        if ~ld2_has_connection(c, req(k,1), req(k,2)) then missing = [missing; req(k,:)]; end
    end
    ok = size(missing,1) == 0;
endfunction

function target = ld2_detect_voltage_target(phase)
    c = ld2_get_phase_connections(phase);
    target = "";
    if phase == "RC" then
        if (ld2_has_connection(c,"VM_H","R8_M1") & ld2_has_connection(c,"VM_L","R8_M2")) | (ld2_has_connection(c,"VM_H","R8_M2") & ld2_has_connection(c,"VM_L","R8_M1")) then target = "UR";
        elseif (ld2_has_connection(c,"VM_H","C2_M1") & ld2_has_connection(c,"VM_L","C2_M2")) | (ld2_has_connection(c,"VM_H","C2_M2") & ld2_has_connection(c,"VM_L","C2_M1")) then target = "UC";
        elseif (ld2_has_connection(c,"VM_H","GEN_MH") & ld2_has_connection(c,"VM_L","GEN_ML")) | (ld2_has_connection(c,"VM_H","GEN_ML") & ld2_has_connection(c,"VM_L","GEN_MH")) then target = "UE"; end
    elseif phase == "RL" then
        if (ld2_has_connection(c,"VM_H","R9_M1") & ld2_has_connection(c,"VM_L","R9_M2")) | (ld2_has_connection(c,"VM_H","R9_M2") & ld2_has_connection(c,"VM_L","R9_M1")) then target = "UR";
        elseif (ld2_has_connection(c,"VM_H","L1_M1") & ld2_has_connection(c,"VM_L","L1_M2")) | (ld2_has_connection(c,"VM_H","L1_M2") & ld2_has_connection(c,"VM_L","L1_M1")) then target = "UL";
        elseif (ld2_has_connection(c,"VM_H","GEN_MH") & ld2_has_connection(c,"VM_L","GEN_ML")) | (ld2_has_connection(c,"VM_H","GEN_ML") & ld2_has_connection(c,"VM_L","GEN_MH")) then target = "UE"; end
    elseif phase == "RLC" then
        if (ld2_has_connection(c,"VM_H","R13_M1") & ld2_has_connection(c,"VM_L","R13_M2")) | (ld2_has_connection(c,"VM_H","R13_M2") & ld2_has_connection(c,"VM_L","R13_M1")) then target = "UR";
        elseif (ld2_has_connection(c,"VM_H","L3_M1") & ld2_has_connection(c,"VM_L","L3_M2")) | (ld2_has_connection(c,"VM_H","L3_M2") & ld2_has_connection(c,"VM_L","L3_M1")) then target = "UL";
        elseif (ld2_has_connection(c,"VM_H","C4_M1") & ld2_has_connection(c,"VM_L","C4_M2")) | (ld2_has_connection(c,"VM_H","C4_M2") & ld2_has_connection(c,"VM_L","C4_M1")) then target = "UC";
        elseif (ld2_has_connection(c,"VM_H","LC_M1") & ld2_has_connection(c,"VM_L","LC_M2")) | (ld2_has_connection(c,"VM_H","LC_M2") & ld2_has_connection(c,"VM_L","LC_M1")) then target = "ULC"; end
    end
endfunction

function [ok,problem,fixes]=ld2_validate_voltage_probes(phase,expected)
    target=ld2_detect_voltage_target(phase); expected_target=ld2_target_code(expected);
    ok=(target==expected_target & target<>""); problem=""; fixes=emptystr(0,1);
    if ok then return; end
    problem="V~ prijungimas netinka. Reikia "+expected_target+"; dabar: "+target+".";
    p=ld2_probe_pair(phase,expected_target);
    if size(p,"*")==2 then
        fixes=["[B13] pašalinkite senus zondus.";"T07 → "+ld2_terminal_code(p(1))+" ir T08 → "+ld2_terminal_code(p(2))+".";"[B09] įjunkite generatorių; [B15] matuokite įtampą."];
    else fixes=ld2_probe_help(phase); end
endfunction

function [ok, msg, fix] = ld2_can_add_pair(step, a, b)
    phase = ld2_phase_for_step(step); c = ld2_get_phase_connections(phase); allowed = ld2_allowed_pairs(step);
    ok = %f; msg = ""; fix = "";
    if a == b then msg = "Pasirinktas tas pats lizdas du kartus."; fix = "Pasirinkite pirmą lizdą, tada kitame komponente pasirinkite antrą lizdą."; return; end
    if ~ld2_pair_in_matrix(a,b,allowed) then
        msg = "Šių dviejų lizdų jungtis šiame etape nereikalinga.";
        [valid, missing] = ld2_validate_main(phase);
        if ~valid then fix = "Kitas reikalingas laidas: " + ld2_terminal_name(missing(1,1)) + " → " + ld2_terminal_name(missing(1,2)) + "."; else fix = strcat(ld2_probe_help(phase)," "); end
        return;
    end
    if ld2_has_connection(c,a,b) then msg = "Toks laidas jau prijungtas."; fix = "Jo nekartokite. Pasirinkite kitą dar nesujungtą porą."; return; end
    if ld2_terminal_used(c,a) then msg = ld2_terminal_name(a) + " jau užimtas kitu laidu."; fix = "[B13] nuimkite voltmetro zondus; pagrindinį laidą sujungimo etape atšaukite [B11]. Tada junkite nurodytą porą iš naujo."; return; end
    if ld2_terminal_used(c,b) then msg = ld2_terminal_name(b) + " jau užimtas kitu laidu."; fix = "[B13] nuimkite voltmetro zondus; pagrindinį laidą sujungimo etape atšaukite [B11]. Tada junkite nurodytą porą iš naujo."; return; end
    ok = %t;
endfunction

function c = ld2_add_pair(c, a, b)
    c = [c; a b];
endfunction

function c = ld2_solution_connections(step)
    phase = ld2_phase_for_step(step); c = ld2_required_main(phase);
    select step
    case 4 then c = [c; "VM_H" "R8_M1"; "VM_L" "R8_M2"];
    case 7 then c = [c; "VM_H" "R9_M1"; "VM_L" "R9_M2"];
    case 9 then c = [c; "VM_H" "R13_M1"; "VM_L" "R13_M2"];
    case 10 then c = [c; "VM_H" "L3_M1"; "VM_L" "L3_M2"];
    case 12 then c = [c; "VM_H" "R13_M1"; "VM_L" "R13_M2"];
    case 11 then c = [c; "VM_H" "R13_M1"; "VM_L" "R13_M2"];
    end
endfunction
