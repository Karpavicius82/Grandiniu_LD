// ============================================================================
// LD8 variantų konfigūracija (bankas LD8-64-A-2026). Nuosekliojo, lygiagretaus
// ir mišriojo jungimo tyrimas: trys rezistoriai E24 nominalais su deterministine
// ±5 % tolerancija. Skaičiavimas bitų lygiu sutampa su core/src/model.cpp.
// ============================================================================

function cfg = ld8_variant_config(number)
    if ~ld8_valid_index(number, 64) then error("Eilės numeris turi būti nuo 1 iki 64."); end
    n1 = [100;120;150;180;220;270;330;390]; n2 = [470;560;680;820;1000;1200;1500;1800];
    n3 = [220;270;330;390;470;560;680;820];
    row = floor((number-1)/8)+1; column = modulo(number-1, 8)+1;
    d1 = modulo(number, 11)-5; d2 = modulo(3*number, 11)-5; d3 = modulo(5*number, 11)-5;
    r1nom = n1(row); r2nom = n2(column); r3nom = n3(modulo(row-1+column-1, 8)+1);
    cfg = struct("E", 12, ...
        "R1", round(r1nom*(1+d1/100)*10)/10, "R2", round(r2nom*(1+d2/100)*10)/10, ...
        "R3", round(r3nom*(1+d3/100)*10)/10, "R1nom", r1nom, "R2nom", r2nom, "R3nom", r3nom);
endfunction

function [valid, why] = ld8_validate_config(cfg)
    valid = %f; why = "Netinkamos priskirtos reikšmės.";
    if typeof(cfg) <> "st" then return; end
    for field = ["E" "R1" "R2" "R3" "R1nom" "R2nom" "R3nom"]
        if ~isfield(cfg, field) then return; end
        value = cfg(field);
        if type(value) <> 1 | size(value, "*") <> 1 then return; end
        if ~isreal(value) | isnan(value) | isinf(value) then return; end
        if value <= 0 then return; end
    end
    if cfg.E <> 12 then return; end
    n1 = [100 120 150 180 220 270 330 390]; n2 = [470 560 680 820 1000 1200 1500 1800];
    n3 = [220 270 330 390 470 560 680 820];
    if ~or(cfg.R1nom == n1) | ~or(cfg.R2nom == n2) | ~or(cfg.R3nom == n3) then return; end
    if abs(cfg.R1/cfg.R1nom-1) > 0.0501 | abs(cfg.R2/cfg.R2nom-1) > 0.0501 | abs(cfg.R3/cfg.R3nom-1) > 0.0501 then return; end
    valid = %t; why = "";
endfunction
