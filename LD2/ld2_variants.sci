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

function student=ld2_empty_student()
    student=struct("number",0,"name","","group","", ...
        "variant_id","NEPASIRINKTA","bank","LD2-64-A-2026");
endfunction

function lines=ld2_parameter_lines(cfg)
    lines=[msprintf("RC: E=%.1f V RMS; f=%.1f Hz; R8=%.0f Ω; C2=%.3f µF.",cfg.E_RC,cfg.F_RC,cfg.R8,cfg.C2*1e6); ...
        msprintf("RL: E=%.1f V RMS; f=%.1f Hz; R9=%.0f Ω; L1=%.3f H.",cfg.E_RL,cfg.F_RL,cfg.R9,cfg.L1); ...
        msprintf("RLC: E=%.1f V RMS; R13=%.0f Ω; L3=%.3f mH; C4=%.3f nF.",cfg.E_RLC,cfg.R13,cfg.L3*1e3,cfg.C4*1e9)];
endfunction

function ok=ld2_apply_student(n,name,group)
    global LD2;
    ok=%f;
    cfg=ld2_variant_config(n);
    [valid,why]=ld2_validate_config(cfg);
    if ~valid then error(why); end
    if n<>LD2.state.student.number then
        teacher=LD2.state.teacher_mode;
        LD2.cfg=cfg; LD2.state=ld2_initial_state(cfg);
        LD2.state.teacher_mode=teacher;
    end
    LD2.state.student=struct("number",n,"name",stripblanks(name),"group",stripblanks(group), ...
        "variant_id",msprintf("LD2-V%02d",n),"bank","LD2-64-A-2026");
    ld2_event("B01", "Priskirtas "+LD2.state.student.variant_id+" pagal sąrašo eilės numerį "+string(n));
    ok=%t;
endfunction

function ld2_choose_student()
    global LD2;
    if LD2.example_active then
        ld2_show_error("Varianto pavyzdyje keisti negalima.",["[B03] MANO DARBAS; tada [B01] STUDENTAS / VARIANTAS."]); return;
    end
    ld2_save_answers();
    st=LD2.state.student; no="";
    if st.number>0 then no=string(st.number); end
    vals=x_mdialog(["[B01] STUDENTAS IR INDIVIDUALUS VARIANTAS"; ...
        "Sąrašo numeris 1–64 = nekintantis varianto numeris."; ...
        "OK priskiria variantą. Cancel nekeičia duomenų."], ...
        ["[F01] Eilės numeris sąraše (1–64)";"[F02] Vardas ir pavardė";"[F03] Grupė"],[no;st.name;st.group]);
    if size(vals,"*")==0 then return; end
    n=ld2_safe_number(vals(1));
    if isnan(n) then ld2_show_error("[F01] nėra skaičius.",["[B01] įveskite tik sveiką numerį, pavyzdžiui, 17, be raidžių."]); return; end
    if n<>floor(n) | n<1 | n>64 then
        ld2_show_error("[F01] numeris nepriklauso 1–64 intervalui.",["Įrašykite savo sąrašo numerį nuo 1 iki 64. 0, 65 ir trupmeniniai numeriai nepriimami."]); return;
    end
    if n<>st.number & st.number>0 then
        pick=x_choose(["[D01] ATŠAUKTI – pirmiau išsaugoti [B05]";"[D02] KEISTI – ankstesnius bandymus išvalyti"], ...
            "Skirtingų variantų matavimų maišyti negalima. Keitimas pradės naują darbą.");
        if pick<>2 then return; end
    end
    ld2_clear_dynamic();
    ok=ld2_apply_student(n,vals(2),vals(3));
    ld2_render_step();
    ld2_show_info("Jūsų variantas priskirtas", ...
        ["Sąrašo Nr. "+string(n)+" → "+LD2.state.student.variant_id;ld2_parameter_lines(LD2.cfg); ...
         "Parametrai visiems etapams jau pritaikyti. [B39] galite juos bet kada peržiūrėti."; ...
         "Pakeitus tik vardą ar grupę to paties varianto matavimai neištrinami."]);
    ld2_maybe_report();
endfunction

function ld2_edit_parameters()
    global LD2;
    ld2_show_info("[B39] Mano priskirti parametrai", ...
        ["Variantas: "+LD2.state.student.variant_id;ld2_parameter_lines(LD2.cfg); ...
         "Šie 64 variantai sukurti virtualiam LD2; tai nėra tikro KL modulio vardinių dydžių duomenys."; ...
         "Kitas variantas pasirenkamas tik [B01]. Tada pradedamas naujas matavimų rinkinys."]);
endfunction
