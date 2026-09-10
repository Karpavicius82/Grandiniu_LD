// Shared registration and immutable variant identity for both laboratories.
function st=student_empty(lab)
    st=struct("number",0,"name","","group","","variant_id","", "bank",lab+"-64-A-2026");
endfunction

function st=student_profile(number,name,group,lab)
    if type(number)==10 then
        raw=stripblanks(number);
        if size(regexp(raw,"/^[0-9]+$/"),"*")==0 then error("Eilės numerį rašykite skaitmenimis nuo 1 iki 64."); end
        number=strtod(raw);
    end
    if type(number)<>1 then error("Eilės numeris turi būti skaičius."); end
    if size(number,"*")<>1 then error("Įveskite vieną eilės numerį."); end
    if ~isreal(number) then error("Eilės numeris turi būti realus skaičius."); end
    if isnan(number) | isinf(number) then error("Netinkamas eilės numeris."); end
    if number<1 | number>64 | floor(number)<>number then error("Eilės numeris turi būti sveikas nuo 1 iki 64."); end
    name=stripblanks(name); group=stripblanks(group);
    if name=="" then error("Įveskite vardą ir pavardę."); end
    if group=="" then error("Įveskite grupę."); end
    st=struct("number",number,"name",name,"group",group, ...
        "variant_id",msprintf("%s-V%02d",lab,number),"bank",lab+"-64-A-2026");
endfunction

function lines=student_parameter_lines(lab,cfg)
    if lab=="LD1" then
        lines=[msprintf("Šaltinis: %.1f V DC.",cfg.E); ...
            msprintf("R1 = %.0f Ω; R2 = %.0f Ω; R3 = %.0f Ω.",cfg.R1,cfg.R2,cfg.R3); ...
            "VR1 keičiamas pagal etapą: 1000, 500 arba 0 Ω."];
    else
        lines=[msprintf("RC: %.1f V RMS; %.1f Hz; R8 = %.0f Ω; C2 = %.2f µF.",cfg.E_RC,cfg.F_RC,cfg.R8,cfg.C2*1e6); ...
            msprintf("RL: %.1f V RMS; %.1f Hz; R9 = %.0f Ω; L1 = %.3f H.",cfg.E_RL,cfg.F_RL,cfg.R9,cfg.L1); ...
            msprintf("RLC: %.1f V RMS; R13 = %.0f Ω; L3 = %.0f mH; C4 = %.0f nF.",cfg.E_RLC,cfg.R13,cfg.L3*1e3,cfg.C4*1e9)];
    end
endfunction

function text=student_caption(st)
    text="";
    if st.number>0 then text=st.name+" · "+st.group+" · "+st.variant_id; end
endfunction

function [ok,st,cfg]=student_enroll(lab,previous)
    global BENCH_STUDENT;
    if argn(2)<2 then
        previous=student_empty(lab);
        if typeof(BENCH_STUDENT)=="st" then previous=BENCH_STUDENT; end
    end
    no=""; if previous.number>0 then no=string(previous.number); end
    defaults=[no;previous.name;previous.group]; ok=%f; st=previous; cfg=[];
    while %t
        values=x_mdialog([lab+" · Jūsų duomenys";"Eilės numeris priskiria pastovias stendo reikšmes."], ...
            ["Eilės numeris sąraše (1–64)";"Vardas ir pavardė";"Grupė"],defaults);
        if size(values,"*")==0 then return; end
        defaults=values;
        try
            st=student_profile(values(1),values(2),values(3),lab);
            if lab=="LD1" then cfg=ld1_variant_config(st.number);
            else
                cfg=ld2_variant_config(st.number);
                [valid,why]=ld2_validate_config(cfg); if ~valid then error(why); end
            end
        catch
            messagebox(lasterror(),"Patikrinkite duomenis","error","modal"); continue;
        end
        pick=messagebox([student_caption(st);"";student_parameter_lines(lab,cfg); ...
            "";"Šios reikšmės bus naudojamos visuose darbo etapuose."], ...
            "Jūsų priskirtos reikšmės","info",["Pradėti" "Taisyti"],"modal");
        if pick==1 then ok=%t; return; end
        if pick==0 then return; end
    end
endfunction

function student_remember(st)
    global BENCH_STUDENT;
    BENCH_STUDENT=st;
endfunction

function lines=student_csv_lines(st)
    q=ascii(34);
    function out=quote(txt)
        out=q+strsubst(string(txt),q,q+q)+q;
    endfunction
    lines=["Laukas;Reiksme";"Eiles_numeris;"+string(st.number); ...
        "Vardas_pavarde;"+quote(st.name);"Grupe;"+quote(st.group); ...
        "Variantas;"+quote(st.variant_id);"Variantu_bankas;"+quote(st.bank)];
endfunction
