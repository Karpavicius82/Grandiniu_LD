function cfg = ld1_config()
    // LD Nr.1 konfigūracija.
    // R1, R2 ir R3 skaitinės vertės pirmame laboratorinio darbo apraše nepateiktos.
    // Todėl jos sąmoningai paliekamos 0 ir pirmo paleidimo metu paprašomos įvesti.
    cfg = struct();
    cfg.title = "LD Nr. 1. Nuolatinės srovės grandinės tyrimas";
    cfg.E = 10;                 // V, tiesiogiai nurodyta laboratorinio apraše
    cfg.R1 = 0;                 // Ω, įveda dėstytojas / vartotojas
    cfg.R2 = 0;                 // Ω, įveda dėstytojas / vartotojas
    cfg.R3 = 0;                 // Ω, įveda dėstytojas / vartotojas
    cfg.VR1_min = 0;            // Ω
    cfg.VR1_max = 1000;         // Ω: darbui reikalingi 0, 500 ir 1000 Ω taškai
    cfg.VR1_step = 10;          // Ω
    cfg.answer_tolerance = 0.01; // 1 % skaitinio atsakymo tolerancija
    cfg.meter_R_A = 0.05;       // Ω, naudojama tik realistiškame režime
    cfg.meter_R_V = 1e7;        // Ω, naudojama tik realistiškame režime
    cfg.realistic_default = %f; // pagal nutylėjimą idealus režimas
    cfg.resistor_tolerance = 0.01; // ±1 % realistiškame režime
    cfg.meter_noise = 0.002;       // ±0.2 % realistiškame režime
endfunction

// New virtual bank for the student interface; not physical kit nominal values.
// Eight R1 levels x eight R2 levels; R3 cycles deterministically through E12 values.
function cfg=ld1_variant_config(n)
    student_profile(n,"Testas","Testas","LD1");
    values=[330 470 680 820 1000 1200 1500 2200];
    a=floor((n-1)/8)+1; b=modulo(n-1,8)+1;
    cfg=ld1_config();
    cfg.R1=values(a); cfg.R2=values(b); cfg.R3=values(modulo(a+b-2,8)+1);
endfunction
