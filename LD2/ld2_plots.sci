// Only these functions create graphics axes; the bench itself uses native controls.
function f=ld2_graph_window(key,title)
    global LD2;
    if ~isfield(LD2.ui,"plot_keys") then LD2.ui.plot_keys=emptystr(0,1); LD2.ui.plot_ids=[]; end
    pos=find(LD2.ui.plot_keys==key); id=-1; if size(pos,"*")>0 then id=LD2.ui.plot_ids(pos(1)); end
    if or(winsid()==id) then f=scf(id); clf(f);
    else f=figure(); if size(pos,"*")==0 then LD2.ui.plot_keys($+1,1)=key; LD2.ui.plot_ids($+1,1)=f.figure_id; else LD2.ui.plot_ids(pos(1))=f.figure_id; end; end
    f.figure_name=title;
endfunction

function ld2_plot_current()
    global LD2; step=LD2.state.step;
    if step==3 | step==4 | step==6 | step==7 then ld2_plot_voltage_current();
    elseif step==10 then
        target=ld2_detect_voltage_target("RLC"); if ~or(target==["UL" "UC" "ULC"]) then target="UL"; end
        idx=find(LD2.state.peak_target==target); if size(idx,"*")==0 then ld2_show_error("Dar nėra "+target+" paieškos taškų.",["[B15] matuokite, [B23] fiksuokite. Taikinį nulemia prijungti T07/T08 zondai."]); return; end
        [x,ix]=gsort(LD2.state.peak_f(idx),"g","i"); y=LD2.state.peak_u(idx); y=y(ix);
        f=ld2_graph_window("peaks","E10 – užfiksuotas "+target); plot2d(x,y,-4); xgrid(); xtitle("E10: "+target+" užfiksuoti taškai","f, Hz","U, V RMS");
    elseif step==11 then
        if isnan(LD2.state.f1_meas) | isnan(LD2.state.f2_meas) then ld2_show_error("Dar trūksta ribinių taškų.",["[B24] užfiksuokite f1; [B25] užfiksuokite f2. Tada [B31] grafikas."]); return; end
        f=ld2_graph_window("halfpower","E11 – užfiksuotos ribos"); plot2d([LD2.state.f1_meas;LD2.state.f2_meas],[LD2.state.f1_u;LD2.state.f2_u],-4); xgrid(); xtitle("Tik du išmatuoti ribiniai taškai – ne visa rezonanso kreivė","f, Hz","UR13, V RMS");
    elseif step==9 | step==12 then ld2_plot_resonance(); else ld2_show_summary_window(); end
endfunction

function ld2_plot_scope_current()
    global LD2; phase=ld2_phase_for_step(LD2.state.step); [ok,missing]=ld2_validate_main(phase);
    if ~ok | ~LD2.state.power then ld2_show_error("Oscilogramai reikia uždaros grandinės ir įjungto generatoriaus.",["Sujunkite pagrindinius laidus ir įjunkite generatorių."]); return; end
    ld2_plot_scope(phase);
endfunction

function ld2_plot_scope(phase)
    global LD2; f0=ld2_current_frequency(phase);
    if phase=="RC" then r=ld2_rc_values(LD2.cfg.E_RC,f0,LD2.cfg.R8,LD2.cfg.C2); E=LD2.cfg.E_RC; phi=r.PHI_I*%pi/180;
    elseif phase=="RL" then r=ld2_rl_values(LD2.cfg.E_RL,f0,LD2.cfg.R9,LD2.cfg.L1); E=LD2.cfg.E_RL; phi=r.PHI_I*%pi/180;
    else r=ld2_rlc_values(LD2.cfg.E_RLC,f0,LD2.cfg.R13,LD2.cfg.L3,LD2.cfg.C4); E=LD2.cfg.E_RLC; phi=-r.PHI*%pi/180; end
    t=linspace(0,2/f0,801)'; u=sqrt(2)*E*sin(2*%pi*f0*t); ur=sqrt(2)*r.UR*sin(2*%pi*f0*t+phi);
    fig=ld2_graph_window("scope",phase+" – virtuali oscilograma"); plot2d(t*1000,[u ur],[2 5]); xgrid();
    xtitle(msprintf("%s | f = %.3f Hz | T = %.6f ms",phase,f0,1000/f0),"t, ms","u, V (momentinė)"); legend(["Šaltinio u(t)";"Rezistoriaus uR(t) = R*i(t)"]);
endfunction

function ld2_plot_voltage_current()
    global LD2; phase=ld2_phase_for_step(LD2.state.step);
    if phase=="RC" | phase=="RL" then ld2_plot_phasor(phase); else ld2_show_info("Diagrama",["Šis mygtukas skirtas RC ir RL įtampų vektoriams."]); end
endfunction

function ld2_plot_phasor(phase)
    global LD2;
    if phase=="RC" then r=ld2_rc_values(LD2.cfg.E_RC,LD2.cfg.F_RC,LD2.cfg.R8,LD2.cfg.C2); yreact=-r.UX; name="UC";
    else r=ld2_rl_values(LD2.cfg.E_RL,LD2.cfg.F_RL,LD2.cfg.R9,LD2.cfg.L1); yreact=r.UX; name="UL"; end
    fig=ld2_graph_window("voltage",phase+" – įtampų vektoriai"); plot2d([0 0 0;r.UR 0 r.UR],[0 0 0;0 yreact yreact],[2 3 5]); xgrid(); a=gca(); a.isoview="on";
    xtitle(phase+" | įtampų vektoriai: I fazė = 0°","Re, V RMS","Im, V RMS"); legend(["UR";name;"E = UR + UX (vektoriškai)"]);
endfunction

function ld2_plot_impedance()
    global LD2; phase=ld2_phase_for_step(LD2.state.step);
    if phase=="RC" then r=ld2_rc_values(LD2.cfg.E_RC,LD2.cfg.F_RC,LD2.cfg.R8,LD2.cfg.C2); R=LD2.cfg.R8; X=-r.X;
    elseif phase=="RL" then r=ld2_rl_values(LD2.cfg.E_RL,LD2.cfg.F_RL,LD2.cfg.R9,LD2.cfg.L1); R=LD2.cfg.R9; X=r.X; else return; end
    fig=ld2_graph_window("impedance",phase+" – varžų vektoriai R, X, Z"); plot2d([0 0 0;R 0 R],[0 0 0;0 X X],[2 3 5]); xgrid(); a=gca(); a.isoview="on";
    xtitle(msprintf("%s | Z = R + jX | phiZ = %.4f°, phiI = %.4f°",phase,r.PHI_Z,r.PHI_I),"Re, Ω","Im, Ω"); legend(["R";"jX";"Z"]);
endfunction

function ld2_plot_resonance()
    global LD2;
    if LD2.state.step==12 then fdata=LD2.state.sweep_f; udata=LD2.state.sweep_ur; data_label="12 etapo lentelės taškai (0 Hz – teorinė riba)";
    else fdata=LD2.state.res_f; udata=LD2.state.res_ur; data_label="9 etape užfiksuoti V~ taškai"; end
    if size(fdata,"*")==0 then ld2_show_error("Nėra užfiksuotų taškų grafikui.",["9 etape spauskite MATUOTI U → ĮRAŠYTI TAŠKĄ; 12 etape atlikite skenavimą.";"Teorinį variantą galite pamatyti PAVYZDYJE."]); return; end
    [fs,order]=gsort(matrix(fdata,-1,1),"g","i"); us=matrix(udata,-1,1); us=us(order);
    fig=ld2_graph_window("resonance","RLC – jūsų užfiksuoti taškai"); plot2d(fs,us,2); a=gca(); a.auto_clear="off"; plot2d(fs,us,-4); xgrid(); xtitle("RLC: "+data_label,"f, Hz","UR13, V RMS");
endfunction

function ld2_show_summary_window()
    global LD2; rows=emptystr(0,1);
    for step=1:12
        if LD2.state.completed(step)==1 then result="PATIKRINTA"; elseif LD2.state.skipped(step)==1 then result="PRALEISTA"; else result="NEATLIKTA"; end
        rows($+1,1)=ld2_step_title(step)+" — "+result; [labels,n]=ld2_answer_spec(step);
        for j=1:n raw=LD2.state.answers_text(step,j); if raw=="" then raw="NEĮVESTA"; end; rows($+1,1)="    Studento įvestis: "+labels(j)+" = "+raw; end
    end
    ld2_text_window("LD2 – įvesčių ir etapų suvestinė",rows);
endfunction

function ld2_show_journal()
    global LD2; rows=emptystr(0,1);
    for k=1:length(LD2.state.measurements) m=LD2.state.measurements(k); rows($+1,1)=msprintf("#%d | %d etapas | %s | %s | %s",m.id,m.step,m.phase,ld2_reading_text(m),m.origin); end
    if size(rows,"*")==0 then rows="NEATLIKTA – matavimų dar nėra."; end
    ld2_text_window("LD2 – visų virtualių matavimų žurnalas",rows);
endfunction

function ld2_close_aux(id)
    if or(winsid()==id) then delete(scf(id)); end
endfunction
