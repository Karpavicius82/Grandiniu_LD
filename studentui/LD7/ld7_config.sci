// ============================================================================
// LD7 variantų konfigūracija (bankas LD7-64-A-2026). Įtampos, srovės ir
// galios suderinamumo tyrimas: šaltinis E su vidine varža r (E12 serija),
// reostatas penkiose padėtyse R_k = round(m_k·r·10)/10 apiplaukia r iš abiejų
// pusių (R3 = r — suderinamumo režimas). Skaičiavimas bitų lygiu sutampa su
// core/src/model.cpp banku (tokie patys daugikliai ir apvalinimas).
// ============================================================================

function cfg = ld7_variant_config(number)
    if ~ld7_valid_index(number, 64) then error("Eilės numeris turi būti nuo 1 iki 64."); end
    voltages = [3;4;5;6;7;8;10;12]; internal = [22;27;33;39;47;56;68;82];
    row = floor((number-1)/8)+1; column = modulo(number-1, 8)+1;
    r = internal(row); mult = [0.33 0.56 1.0 1.8 3.0];
    cfg = struct("E", voltages(column), "r", r, ...
        "R1", round(mult(1)*r*10)/10, "R2", round(mult(2)*r*10)/10, ...
        "R3", round(mult(3)*r*10)/10, "R4", round(mult(4)*r*10)/10, ...
        "R5", round(mult(5)*r*10)/10);
endfunction

function [valid, why] = ld7_validate_config(cfg)
    valid = %f; why = "Netinkamos priskirtos reikšmės.";
    if typeof(cfg) <> "st" then return; end
    for field = ["E" "r" "R1" "R2" "R3" "R4" "R5"]
        if ~isfield(cfg, field) then return; end
        value = cfg(field);
        if type(value) <> 1 | size(value, "*") <> 1 then return; end
        if ~isreal(value) | isnan(value) | isinf(value) then return; end
        if value <= 0 then return; end
    end
    if ~or(cfg.E == [3 4 5 6 7 8 10 12]) | ~or(cfg.r == [22 27 33 39 47 56 68 82]) then return; end
    mult = [0.33 0.56 1.0 1.8 3.0];
    values = [cfg.R1 cfg.R2 cfg.R3 cfg.R4 cfg.R5];
    for k = 1:5
        if abs(values(k) - round(mult(k)*cfg.r*10)/10) > 1e-9 then return; end
    end
    if cfg.R3 <> cfg.r then return; end
    for k = 1:4
        if values(k) >= values(k+1) then return; end
    end
    valid = %t; why = "";
endfunction
