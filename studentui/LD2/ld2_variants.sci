// Original LD2-64-A-2026 bank from Grandiniu_LD commit 77e443a.
// LD2-64-A-2026: deterministic assignment, no randomisation.
function cfg=ld2_variant_config(n)
    if type(n)<>1 then error("Numeris turi būti skaičius."); end
    if size(n,"*")<>1 then error("Įveskite vieną eilės numerį."); end
    if ~isreal(n) then error("Numeris negali būti kompleksinis."); end
    if isnan(n) | isinf(n) then error("Netinkamas eilės numeris."); end
    if n<>floor(n) | n<1 | n>64 then error("Eilės numeris turi būti sveikas nuo 1 iki 64."); end
    a=floor((n-1)/8)+1; b=modulo(n-1,8)+1;
    cfg=ld2_default_config();
    r8=[330 470 680 820 1000 1200 1500 1800];
    r9=[100 150 180 220 270 330 390 470];
    lv=[10 12 15 18 22 27 33 39]; cv=[47 56 68 82 100 120 150 180];
    cfg.R8=r8(a); cfg.F_RC=35+5*b;
    cfg.R9=r9(b); cfg.F_RL=35+5*a;
    cfg.C2=4.7e-6; cfg.L1=0.5;
    cfg.E_RC=9; cfg.E_RL=9; cfg.E_RLC=5;
    cfg.L3=lv(a)*1e-3; cfg.C4=cv(b)*1e-9;
    cfg.R13=round(sqrt(cfg.L3/cfg.C4)/(2.8+0.35*a+0.20*b));
    cfg.F_INIT=1000;
endfunction
