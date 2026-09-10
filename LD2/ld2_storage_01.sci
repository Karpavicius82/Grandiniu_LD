// LD2 v2.0 sessions intentionally do not silently import v1.x data.
function ld2_save_session_to(path)
    global LD2;
    if LD2.example_active then error("Pavyzdžio negalima išsaugoti kaip studento sesijos."); end
    session=struct("format","LD2-2.0","bank","LD2-64-A-2026","cfg",LD2.cfg,"state",LD2.state);
    save(path,"session");
endfunction

function [ok,why]=ld2_validate_session(session)
    ok=%f; why="";
    if ~isfield(session,"format") then why="Tai ne LD2 sesija."; return; end
    if session.format<>"LD2-2.0" then why="Reikalinga v2.0 sesija. v1.x failai neturi priskirto 64 variantų banko."; return; end
    try
        c=session.cfg; s=session.state;
        [valid,why]=ld2_validate_config(c); if ~valid then return; end
        n=s.student.number;
        if n<1 then expected=ld2_variant_config(1); else expected=ld2_variant_config(n); end
        names=fieldnames(expected);
        for j=1:size(names,"*")
            name=names(j);
            if ld2_config_value(c,name)<>ld2_config_value(expected,name) then why="Parametras "+name+" neatitinka priskirto varianto. Skirtingų variantų duomenys nemaišomi."; return; end
        end
        if s.student.bank<>"LD2-64-A-2026" then why="Kitas variantų bankas."; return; end
        if s.step<1 | s.step>12 | floor(s.step)<>s.step then why="Netinkamas etapas."; return; end
        if or(size(s.answers_text)<>[12 8]) | or(size(s.answers)<>[12 8]) then why="Netinkami atsakymų matmenys."; return; end
        if size(s.completed,"*")<>12 | size(s.step_notes,"*")<>12 | length(s.step_connections)<>12 then why="Trūksta etapo duomenų."; return; end
        required=["events" "measurements" "student" "started_at" "step_checked_at" "example_views" "auto_prepared" "visits" "report_signature"];
        for name=required; if ~isfield(s,name) then why="Trūksta "+name; return; end; end
        if isnan(s.freq) | isinf(s.freq) | s.freq<1 | s.freq>c.F_MAX then why="Neteisingas dažnis."; return; end
        for phase=["RC" "RL" "RLC"]
            if phase=="RC" then wires=s.rc_connections; base=ld2_allowed_pairs(4);
            elseif phase=="RL" then wires=s.rl_connections; base=ld2_allowed_pairs(7);
            else wires=s.rlc_connections; base=[ld2_allowed_pairs(9);ld2_allowed_pairs(10)]; end
            used=emptystr(0,1);
            for j=1:size(wires,1)
                a=wires(j,1); b=wires(j,2);
                if ~ld2_pair_in_matrix(a,b,base) then why="Sesijoje yra stendui nepriklausanti jungtis."; return; end
                if or(used==a) | or(used==b) then why="Vienas kontaktas panaudotas du kartus."; return; end
                used=[used;a;b];
            end
        end
        ok=%t;
    catch
        why="Sesijos struktūra sugadinta: "+strcat(lasterror()," ");
    end
endfunction

function ld2_save_work()
    global LD2;
    if LD2.example_active then ld2_show_error("Pavyzdys nėra jūsų darbas.",["Pirma spauskite MANO DARBAS, tada IŠSAUGOTI."]); return; end
    ld2_save_answers();
    name=uiputfile("*.sod",LD2.root,"Išsaugoti LD2 darbą");
    if size(name,"*")==0 then return; end
    if type(name)<>10 then return; end
    if stripblanks(name)=="" then return; end
    path=name;
    if length(path)<4 then path=path+".sod";
    elseif convstr(part(path,length(path)-3:length(path)),"l")<>".sod" then path=path+".sod"; end
    try
        ld2_save_session_to(path); ld2_set_status("Darbas išsaugotas: "+path,"ok");
    catch
        ld2_show_error("Nepavyko išsaugoti darbo.",[lasterror();"Pasirinkite aplanką, kuriame turite rašymo teises."]);
    end
endfunction

function ld2_load_work()
    global LD2;
    if LD2.example_active then ld2_show_error("Pirmiausia uždarykite pavyzdį.",["Spauskite MANO DARBAS."]); return; end
    name=uigetfile("*.sod",LD2.root,"[B06] Atverti išsaugotą LD2 v2.0 darbą");
    if size(name,"*")==0 then return; end
    if type(name)<>10 then return; end
    if stripblanks(name)=="" then return; end
    path=name;
    try
        load(path,"session"); [valid,why]=ld2_validate_session(session); if ~valid then error(why); end
    catch
        ld2_show_error("Sesija neįkelta; jūsų dabartinis darbas nepakeistas.",[lasterror();"Pasirinkite šios versijos IŠSAUGOTI sukurtą .sod failą."]); return;
    end
    ld2_clear_dynamic(); LD2.cfg=session.cfg; LD2.state=session.state; LD2.state.power=%f; LD2.state.selected_terminal="";
    ld2_reset_live_readings(ld2_phase_for_step(LD2.state.step)); ld2_render_step();
    ld2_set_status("Darbas atkurtas. Laidai ir istorija išliko; generatorius išjungtas, gyvą rodmenį išmatuokite iš naujo.","ok");
endfunction

function out=ld2_csv_field(txt)
    q=ascii(34); text=string(txt);
    if length(text)>0 then first=part(text,1); if or(first==["=" "+" "-" "@"]) & isnan(ld2_safe_number(text)) then text=ascii(39)+text; end; end
    out=q+strsubst(text,q,q+q)+q;
endfunction

function row=ld2_csv_row(fields)
    quoted=emptystr(1,size(fields,"*"));
    for j=1:size(fields,"*"); quoted(j)=ld2_csv_field(fields(j)); end
    row=strcat(quoted,";");
endfunction

function ld2_export_all()
    global LD2;
    if LD2.example_active then ld2_show_error("Pavyzdžio duomenys neeksportuojami kaip studento darbas.",["Pirmiausia grįžkite į savo darbą."]); return; end
    ld2_save_answers(); folder=uigetdir(LD2.root,"Pasirinkite aplanką LD2 CSV failams");
    if size(folder,"*")==0 then return; end
    if type(folder)<>10 then return; end
    if stripblanks(folder)=="" then return; end
    try ld2_write_exports(folder); ld2_set_status("Išsaugoti matavimai, atsakymai, parametrai ir dažninė lentelė: "+folder,"ok");
    catch ld2_show_error("CSV eksportas nepavyko.",[lasterror();"Pasirinkite rašymui leidžiamą aplanką."]); end
endfunction
