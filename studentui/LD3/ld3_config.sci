// ============================================================================
// LD3 variantų konfigūracija (bankas LD3-64-A-2026).
// R ∈ {120…470} Ω pagal a = floor((n-1)/8); (U1,U2,U3) iš 8 trejetų pagal
// b = modulo(n-1,8). Atitinka core/src/model.cpp bank() — keisti tik kartu.
// ============================================================================

function cfg = ld3_variant_config(n)
    rld = [33; 47; 56; 68; 82; 100; 120; 150];
    uu  = [3 6 9; 4 8 12; 2 5 8; 5 10 12; 3 7 11; 6 9 12; 2 6 10; 4 7 10];
    a = floor((n - 1) / 8);
    b = modulo(n - 1, 8);
    cfg = struct("R", rld(a + 1), "U1", uu(b + 1, 1), "U2", uu(b + 1, 2), "U3", uu(b + 1, 3));
endfunction

function [valid, why] = ld3_validate_config(cfg)
    valid = %t; why = "";
    Rset = [33 47 56 68 82 100 120 150];
    Uset = [3 6 9; 4 8 12; 2 5 8; 5 10 12; 3 7 11; 6 9 12; 2 6 10; 4 7 10];
    if ~isfield(cfg, "R") | ~isfield(cfg, "U1") | ~isfield(cfg, "U2") | ~isfield(cfg, "U3") then
        valid = %f; why = "Trūksta varianto laukų.";
    end
    if valid then
        if size(find(Rset == cfg.R), "*") == 0 then
            valid = %f; why = "R ne iš banko.";
        end
    end
    if valid then
        hit = 0;
        for k = 1:8
            if Uset(k,1) == cfg.U1 & Uset(k,2) == cfg.U2 & Uset(k,3) == cfg.U3 then
                hit = hit + 1;
            end
        end
        if hit == 0 then
            valid = %f; why = "Įtampų trejetas ne iš banko.";
        end
    end
    if valid then
        if ~(cfg.U1 < cfg.U2 & cfg.U2 < cfg.U3) then
            valid = %f; why = "Įtampos turi didėti.";
        end
    end
endfunction
