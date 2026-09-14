// ============================================================================
// LD5 variantų konfigūracija (bankas LD5-64-A-2026). Įtampos daliklis:
// R1 (E24) + potenciometras RV (E24, realus ±5 %), trys padėtys %.
// ============================================================================

function cfg = ld5_variant_config(n)
    if ~ld5_valid_index(n,64) then error("Eilės numeris turi būti sveikas skaičius nuo 1 iki 64."); end
    r1nom = [100; 120; 150; 180; 220; 270; 330; 390];
    rvnom = [470; 560; 680; 820; 1000; 1200; 1500; 1800];
    pp    = [25 50 75; 20 45 70; 30 55 80; 15 40 65; 35 60 85; 25 60 90; 10 50 80; 30 50 70];
    a = floor((n - 1) / 8);
    b = modulo(n - 1, 8);
    d1 = modulo(n, 11) - 5;
    d2 = modulo(3 * n, 11) - 5;
    cfg = struct("R1nom", r1nom(a + 1), "RVnom", rvnom(b + 1), ...
                 "R1", round(r1nom(a + 1) * (1 + d1 / 100) * 10) / 10, ...
                 "RV", round(rvnom(b + 1) * (1 + d2 / 100) * 10) / 10, ...
                 "E", 9, ...
                 "P1", pp(b + 1, 1), "P2", pp(b + 1, 2), "P3", pp(b + 1, 3));
endfunction

function [valid, why] = ld5_validate_config(cfg)
    valid = %t; why = "";
    n1 = [100 120 150 180 220 270 330 390];
    n2 = [470 560 680 820 1000 1200 1500 1800];
    pp = [25 50 75; 20 45 70; 30 55 80; 15 40 65; 35 60 85; 25 60 90; 10 50 80; 30 50 70];
    for field=["R1nom" "RVnom" "R1" "RV" "E" "P1" "P2" "P3"]
        if ~isfield(cfg,field) then valid=%f; why="Trūksta priskirtų reikšmių."; return; end
        v=cfg(field);
        if type(v)<>1 | size(v,"*")<>1 then valid=%f; why="Netinkama priskirta reikšmė."; return; end
        if ~isreal(v) | isnan(v) | isinf(v) then valid=%f; why="Reikšmė turi būti baigtinis skaičius."; return; end
        if v<=0 then valid=%f; why="Reikšmė turi būti teigiama."; return; end
    end
    if cfg.E<>9 then valid=%f; why="LD5 šaltinis turi būti 9 V."; return; end
    if valid then
        if size(find(n1 == cfg.R1nom), "*") == 0 | size(find(n2 == cfg.RVnom), "*") == 0 then
            valid = %f; why = "Nominalai ne iš E24 banko.";
        end
    end
    if valid then
        hit = 0;
        for k = 1:8
            if pp(k,1) == cfg.P1 & pp(k,2) == cfg.P2 & pp(k,3) == cfg.P3 then hit = hit + 1; end
        end
        if hit == 0 then valid = %f; why = "Padėčių trejetas ne iš banko."; end
    end
    if valid then
        if abs(cfg.R1 / cfg.R1nom - 1) > 0.0501 | abs(cfg.RV / cfg.RVnom - 1) > 0.0501 then
            valid = %f; why = "Tolerancija viršija ±5 %.";
        end
    end
endfunction
