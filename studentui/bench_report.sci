function a=bench_answer(id,raw,unit)
    a=struct("id",id,"raw",string(raw),"unit",unit);
endfunction

function a=bench_observation(id,value,unit)
    a=struct("id",id,"value",value,"unit",unit);
endfunction

function r=bench_report_data(lab)
    global LD1 LD2;
    answers=list(); observations=list(); evidence=struct(); params=struct();
    mode="learning";practice=%f;
    if lab=="LD1" then
        if LD1.demoMode then error("Grįžkite iš pavyzdžio į savo darbą prieš išsaugodami ataskaitą."); end
        st=LD1.student; cfg=LD1.cfg;
        if isfield(LD1,"assessment") then if LD1.assessment then mode="assessment"; end; end
        if isfield(LD1,"practice_used") then practice=LD1.practice_used;end
        specs=["2" "1" "Ohm";"2" "2" "mA";"4" "1" "Ohm";"4" "2" "mA";"6" "1" "Ohm";"8" "1" "mA";"8" "2" "mA";"8" "3" "mA"];
        for k=1:size(specs,1)
            step=bench_safe_number(specs(k,1)); q=bench_safe_number(specs(k,2));
            answers($+1)=bench_answer(msprintf("s%d.q%d",step,q),LD1.stepQ(step,q),specs(k,3));
        end
        for step=[1 5]
            raw=""; if LD1.stepType(step)>0 then raw=string(LD1.stepType(step)); end
            answers($+1)=bench_answer(msprintf("s%d.type",step),raw,"choice");
        end
        for step=[3 4 6 7 8]
            raw=""; if LD1.stepYesNo(step)>0 then raw=string(LD1.stepYesNo(step)); end
            answers($+1)=bench_answer(msprintf("s%d.compare",step),raw,"choice");
            unit="mA"; if step==6 | step==7 then unit="V"; end
            observations($+1)=bench_observation(msprintf("s%d.measure",step),LD1.stepMeas(step),unit);
        end
        params=struct("E",cfg.E,"R1",cfg.R1,"R2",cfg.R2,"R3",cfg.R3);
        evidence.wiring=struct();
        for step=[1 5]
            w=emptystr(0,2); meter="";
            if isfield(LD1,"report_wires") then w=LD1.report_wires(step); meter=LD1.report_meter(step); end
            evidence.wiring(msprintf("s%d",step))=struct("pairs",bench_pairs(w),"meter",meter);
        end
        evidence.realistic=LD1.realistic;
        note="";
    else
        if LD2.example_active then error("Grįžkite iš pavyzdžio į savo darbą prieš išsaugodami ataskaitą."); end
        s=LD2.state; st=s.student; cfg=LD2.cfg;
        if isfield(s,"assessment") then if s.assessment then mode="assessment"; end; end
        if isfield(s,"practice_used") then practice=s.practice_used;end
        for step=[3 4 6 7 9 10 11]
            select step
            case 3 then units=["Ohm" "Ohm" "mA" "V" "V" "mW" "deg"];
            case 6 then units=["Ohm" "Ohm" "mA" "V" "V" "mW" "deg"];
            case 4 then units=["V" "mA"];
            case 7 then units=["V" "mA"];
            case 9 then units=["Hz" "Hz" "ms" "V"];
            case 10 then units=["V" "V" "V" "Hz" "Hz" "Hz"];
            case 11 then units=["V" "Hz" "Hz" "Hz" "1"];
            end
            for q=1:size(units,"*"); answers($+1)=bench_answer(msprintf("s%d.q%d",step,q),s.answers_text(step,q),units(q)); end
        end
        fields=["rc_I" "rc_UR" "rc_UC" "rc_UE" "rl_I" "rl_UR" "rl_UL" "rl_UE" "f1_meas" "f2_meas" "f1_u" "f2_u"];
        units=["A" "V" "V" "V" "A" "V" "V" "V" "Hz" "Hz" "V" "V"];
        for k=1:size(fields,"*"); observations($+1)=bench_observation(fields(k),s(fields(k)),units(k)); end
        for field=["E_RC" "F_RC" "R8" "C2" "E_RL" "F_RL" "R9" "L1" "E_RLC" "R13" "L3" "C4"]
            params(field)=cfg(field);
        end
        evidence.wiring=struct("RC",bench_pairs(s.rc_connections),"RL",bench_pairs(s.rl_connections),"RLC",bench_pairs(s.rlc_connections));
        evidence.resonance=list();
        for k=1:size(s.res_f,"*"); evidence.resonance($+1)=struct("f",s.res_f(k),"u",s.res_ur(k)); end
        evidence.peaks=list();
        for k=1:size(s.peak_f,"*"); evidence.peaks($+1)=struct("target",s.peak_target(k),"f",s.peak_f(k),"u",s.peak_u(k)); end
        evidence.sweep=list();
        for k=1:size(s.sweep_f,"*"); evidence.sweep($+1)=struct("f",s.sweep_f(k),"u",s.sweep_ur(k)); end
        evidence.journal=s.measurements;
        note=s.free_note;
    end
    if st.number<1 then error("Pirmiausia įveskite studento duomenis ir eilės numerį."); end
    r=struct("schema_version",1,"lab_id",lab,"lab_revision","1","rubric_version",lab+"-1", ...
        "bank_id",st.bank,"variant",st.number,"submission_id",bench_id(),"mode",mode, ...
        "student",struct("number",st.number,"name",st.name,"group",st.group), ...
        "parameters",params,"answers",answers,"observations",observations,"evidence",evidence,"note",note,"practice_used",practice);
endfunction

function path=bench_export_report(lab,folder)
    if argn(2)<2 then folder=bench_documents(); end
    r=bench_report_data(lab);
    payload=strsubst(toJSON(r),"<",ascii(92)+"u003c");
    rows="";
    for k=1:length(r.answers)
        a=r.answers(k); raw=a.raw; if stripblanks(raw)=="" then raw="Neįvesta"; end
        rows=rows+"<tr><td>"+bench_html(a.id)+"</td><td>"+bench_html(raw)+"</td><td>"+bench_html(a.unit)+"</td></tr>";
    end
    measures="";
    for k=1:length(r.observations)
        a=r.observations(k); v="Neišmatuota"; if ~isnan(a.value) then v=msprintf("%.12g",a.value); end
        measures=measures+"<tr><td>"+bench_html(a.id)+"</td><td>"+v+"</td><td>"+bench_html(a.unit)+"</td></tr>";
    end
    doc="<!doctype html><html lang=""lt""><meta charset=""utf-8""><meta name=""viewport"" content=""width=device-width""><title>"+r.lab_id+" ataskaita</title>"+ ...
        "<style>body{font:16px system-ui;max-width:960px;margin:2rem auto;padding:1rem;color:#203237}table{border-collapse:collapse;width:100%}td,th{padding:.5rem;border-bottom:1px solid #ddd;text-align:left}pre{white-space:pre-wrap}h1,h2{color:#17645a}</style>"+ ...
        "<h1>"+r.lab_id+" · studento ataskaita</h1><p>"+bench_html(r.student.name)+" · "+bench_html(r.student.group)+ ...
        " · eilės numeris "+string(r.variant)+"</p><p>Variantų bankas: "+bench_html(r.bank_id)+". Režimas: "+r.mode+".</p>"+ ...
        "<h2>Priskirtos reikšmės</h2><pre>"+bench_html(toJSON(r.parameters))+"</pre><h2>Studento atsakymai</h2><table><tr><th>Laukas</th><th>Atsakymas</th><th>Vienetas</th></tr>"+rows+"</table>"+ ...
        "<h2>Matavimai</h2><table>"+measures+"</table><h2>Išvados</h2><pre>"+bench_html(r.note)+"</pre>"+ ...
        "<details><summary>Bandymų taškai ir sujungimai</summary><pre>"+bench_html(toJSON(r.evidence))+"</pre></details>"+ ...
        "<p>Šį vieną HTML failą persiųskite dėstytojui. Vertinimo programa patikrins jame išsaugotus atsakymus.</p>"+ ...
        "<script type=""application/json"" id=""ld-data"">"+payload+"</script></html>";
    path=fullfile(folder,r.lab_id+"-V"+msprintf("%02d",r.variant)+"-"+r.submission_id+".html");
    bench_write_new(path,doc);
endfunction

function bench_export_current(lab)
    global LD1 LD2;
    try
        if lab=="LD1" then ld1_save_step_inputs(); else ld2_save_answers(); end
        path=bench_export_report(lab);
        if lab=="LD1" then ld1_set_status("Ataskaita išsaugota: "+path,"ok","Persiųskite šį HTML failą dėstytojui.");
        else ld2_set_status("Ataskaita išsaugota: "+path+". Persiųskite šį HTML failą dėstytojui.","ok"); end
    catch
        if lab=="LD1" then ld1_set_status(strcat(lasterror()," "),"error","");
        else ld2_set_status(strcat(lasterror()," "),"error"); end
    end
endfunction
