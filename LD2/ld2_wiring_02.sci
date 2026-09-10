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
