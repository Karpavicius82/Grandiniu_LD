// ============================================================================
// LD4 variantų konfigūracija (bankas LD4-64-A-2026). Tiesinių rezistorių
// tyrimas: DU rezistoriai su realiomis reikšmėmis (E24 nominalai, ±5 %
// deterministinė tolerancija pagal variantą). Atitinka core/src/model.cpp.
// ============================================================================

function cfg = ld4_variant_config(n)
    r1nom = [100; 120; 150; 180; 220; 270; 330; 390];         // E24 a
    r2nom = [470; 560; 680; 820; 1000; 1200; 1500; 1800];     // E24 b
    uu    = [3 6 9; 4 8 12; 2 5 8; 5 10 12; 3 7 11; 6 9 12; 2 6 10; 4 7 10];
    a = floor((n - 1) / 8);
    b = modulo(n - 1, 8);
    d1 = modulo(n, 11) - 5;        // -5..+5 %, deterministina
    d2 = modulo(3 * n, 11) - 5;
    cfg = struct("R1nom", r1nom(a + 1), "R2nom", r2nom(b + 1), ...
                 "R1", round(r1nom(a + 1) * (1 + d1 / 100) * 10) / 10, ...
                 "R2", round(r2nom(b + 1) * (1 + d2 / 100) * 10) / 10, ...
                 "U1", uu(b + 1, 1), "U2", uu(b + 1, 2), "U3", uu(b + 1, 3));
endfunction

function [valid, why] = ld4_validate_config(cfg)
    valid = %t; why = "";
    n1 = [100 120 150 180 220 270 330 390];
    n2 = [470 560 680 820 1000 1200 1500 1800];
    uu = [3 6 9; 4 8 12; 2 5 8; 5 10 12; 3 7 11; 6 9 12; 2 6 10; 4 7 10];
    if ~isfield(cfg, "R1nom") | ~isfield(cfg, "R2nom") | ~isfield(cfg, "R1") | ~isfield(cfg, "R2") then
        valid = %f; why = "Trūksta varianto laukų.";
    end
    if valid then
        if size(find(n1 == cfg.R1nom), "*") == 0 | size(find(n2 == cfg.R2nom), "*") == 0 then
            valid = %f; why = "Nominalai ne iš E24 banko.";
        end
    end
    if valid then
        hit = 0;
        for k = 1:8
            if uu(k,1) == cfg.U1 & uu(k,2) == cfg.U2 & uu(k,3) == cfg.U3 then hit = hit + 1; end
        end
        if hit == 0 then valid = %f; why = "Įtampų trejetas ne iš banko."; end
    end
    if valid then
        if abs(cfg.R1 - cfg.R1nom) / cfg.R1nom > 0.0501 | abs(cfg.R2 - cfg.R2nom) / cfg.R2nom > 0.0501 then
            valid = %f; why = "Tolerancija viršija ±5 %.";
        end
    end
endfunction
