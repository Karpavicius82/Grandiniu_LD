// ============================================================================
// LD9 pagalbinės funkcijos: statusas, skaičių skaitymas, headless apsaugos.
// ============================================================================

function ld9_set_status(msg, kind, hint)
    global LD9;
    if argn(2) < 3 then hint = ""; end
    if argn(2) < 2 then kind = "info"; end
    if isfield(LD9, "ui") then
        if isfield(LD9.ui, "headless") then
            if LD9.ui.headless then return; end
        end
        if isfield(LD9.ui, "statusMain") & is_handle_valid(LD9.ui.statusMain) then
            LD9.ui.statusMain.string = msg;
        end
        if isfield(LD9.ui, "statusFix") & is_handle_valid(LD9.ui.statusFix) then
            LD9.ui.statusFix.string = hint;
        end
    end
endfunction

function v = ld9_parse_number(s)
    v = %nan;
    if exists("bench_safe_number") == 1 then
        v = bench_safe_number(s);
    end
endfunction

function s = ld9_trim(s)
    s = stripblanks(s);
endfunction

function ok = ld9_valid_index(value, maximum)
    ok = %f;
    if type(value) <> 1 | size(value, "*") <> 1 then return; end
    if ~isreal(value) | isnan(value) | isinf(value) then return; end
    ok = value >= 1 & value <= maximum & value == floor(value);
endfunction

// Ignore queued UI events after closing; explicit headless checks remain supported.
function active = ld9_can_act()
    global LD9;
    active=%f;
    if typeof(LD9)<>"st" then return; end
    if isfield(LD9,"ui") then
        if isfield(LD9.ui,"headless") then
            if LD9.ui.headless then active=%t; return; end
        end
    end
    if isfield(LD9,"fig") then active=is_handle_valid(LD9.fig); end
endfunction


// Validate imported local state before touching the open student's work.
function ld9_validate_snapshot(session)
    st=session.state;
    for key=["ui" "fig" "term" "root" "cfg" "student" "autosave_paths" "autosave_error"]
        if isfield(st,key) then error("Juodraštyje yra netinkamas vykdymo laukas: "+key); end
    end
    for key=["step" "answers" "done" "skipped" "freqPoint" "target" "wires" "journal"]
        if ~isfield(st,key) then error("Juodraštyje trūksta LD9 būsenos: "+key); end
    end
    if ~ld9_valid_index(st.step,6) | ~ld9_valid_index(st.freqPoint+1,4) | ~ld9_valid_index(st.target+1,5) then error("Netinkamas juodraščio etapas arba jungimo režimas."); end
    if type(st.answers)<>10 | or(size(st.answers)<>[6 8]) then error("Sugadinti LD9 juodraščio atsakymai."); end
    for key=["done" "skipped"]
        if type(st(key))<>4 | or(size(st(key))<>[1 6]) then error("Sugadinta LD9 etapų būsena."); end
    end
    for key=["assessment" "practice_used"]
        if isfield(st,key) then
            if type(st(key))<>4 | size(st(key),"*")<>1 then error("Sugadinta LD9 darbo režimo žyma."); end
        end
    end
    if isfield(st,"report_wires") then ld9_validate_saved_wires(st.report_wires); end
    ld9_validate_saved_wires(st.wires);
    j=st.journal;
    if j<>[] then
        if type(j)<>1 then error("Sugadintas LD9 matavimų žurnalas."); end
        if ~isreal(j) | size(j,2)<>5 | size(j,1)>12 then error("Netinkami LD9 matavimų žurnalo matmenys."); end
        if or(isnan(j)) | or(isinf(j)) | or(j<=0) then error("Netinkamos LD9 matavimų reikšmės."); end
        for k=1:size(j,1)
            if ~ld9_valid_index(j(k,3),3) | ~ld9_valid_index(j(k,5),4) | sum(j(:,3)==j(k,3) & j(:,5)==j(k,5))<>1 then error("Pasikartojantis arba netinkamas matavimo režimas."); end
        end
    end
endfunction

function ld9_validate_saved_wires(wires)
    if wires==[] then return; end
    if type(wires)<>10 | size(wires,2)<>2 | size(wires,1)>12 then error("Sugadinti LD9 laidai."); end
    ids=ld9_terminal_ids();
    for k=1:size(wires,1)
        a=wires(k,1); b=wires(k,2);
        if ~or(ids==a) | ~or(ids==b) | a==b then error("Nežinomas arba pakartotas LD9 gnybtas."); end
        for n=1:k-1
            if and(wires(n,:)==[a b]) | and(wires(n,:)==[b a]) then error("Juodraštyje kartojasi tas pats laidas."); end
        end
        if sum(wires==a)>2 | sum(wires==b)>2 then error("LD9 gnybte gali būti iki dviejų laidų."); end
    end
endfunction
