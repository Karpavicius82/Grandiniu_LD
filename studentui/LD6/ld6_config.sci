// ============================================================================
// LD6 variantų konfigūracija (bankas LD6-64-A-2026). Šaltinių jungimas:
// E1 = 9 V fiksuotas; E2 pagal variantą; R (krovinys) E24 su ±5 %.
// ============================================================================

function cfg = ld6_variant_config(n)
    e2v = [3; 4; 5; 6; 7; 8; 10; 12];
    rnom = [100; 120; 150; 180; 220; 270; 330; 390];
    a = floor((n - 1) / 8);
    b = modulo(n - 1, 8);
    d = modulo(n, 11) - 5;
    cfg = struct("E1", 9, "E2", e2v(b + 1), ...
                 "Rnom", rnom(a + 1), "R", round(rnom(a + 1) * (1 + d / 100) * 10) / 10);
endfunction

function [valid, why] = ld6_validate_config(cfg)
    valid = %t; why = "";
    e2v = [3 4 5 6 7 8 10 12];
    rnom = [100 120 150 180 220 270 330 390];
    if ~isfield(cfg, "E1") | ~isfield(cfg, "E2") | ~isfield(cfg, "R") | ~isfield(cfg, "Rnom") then
        valid = %f; why = "Trūksta laukų.";
    end
    if valid then
        if size(find(e2v == cfg.E2), "*") == 0 | size(find(rnom == cfg.Rnom), "*") == 0 then
            valid = %f; why = "Reikšmės ne iš banko.";
        end
    end
    if valid then
        if abs(cfg.R / cfg.Rnom - 1) > 0.0501 then
            valid = %f; why = "Tolerancija viršija ±5 %.";
        end
    end
endfunction
