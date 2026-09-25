// ============================================================================
// LD11 pagalbinės funkcijos: statusas, skaičių skaitymas, headless apsaugos.
// ============================================================================

function ld11_set_status(msg, kind, hint)
    global LD11;
    if argn(2) < 3 then hint = ""; end
    if argn(2) < 2 then kind = "info"; end
    if isfield(LD11, "ui") then
        if isfield(LD11.ui, "headless") then
            if LD11.ui.headless then return; end
        end
        if isfield(LD11.ui, "statusMain") & is_handle_valid(LD11.ui.statusMain) then
            LD11.ui.statusMain.string = msg;
        end
        if isfield(LD11.ui, "statusFix") & is_handle_valid(LD11.ui.statusFix) then
            LD11.ui.statusFix.string = hint;
        end
    end
endfunction

function v = ld11_parse_number(s)
    v = %nan;
    if exists("bench_safe_number") == 1 then
        v = bench_safe_number(s);
    end
endfunction

function s = ld11_trim(s)
    s = stripblanks(s);
endfunction

function ok = ld11_valid_index(value, maximum)
    ok = %f;
    if type(value) <> 1 | size(value, "*") <> 1 then return; end
    if ~isreal(value) | isnan(value) | isinf(value) then return; end
    ok = value >= 1 & value <= maximum & value == floor(value);
endfunction

// Ignore queued UI events after closing; explicit headless checks remain supported.
function active = ld11_can_act()
    global LD11;
    active=%f;
    if typeof(LD11)<>"st" then return; end
    if isfield(LD11,"ui") then
        if isfield(LD11.ui,"headless") then
            if LD11.ui.headless then active=%t; return; end
        end
    end
    if isfield(LD11,"fig") then active=is_handle_valid(LD11.fig); end
endfunction


// Reject malformed drafts before changing the open student's work.
function ld11_validate_snapshot(session)
    st=session.state;
    for key=["ui" "fig" "term" "root" "cfg" "student" "autosave_paths" "autosave_error"]
        if isfield(st,key) then error("Netinkamas juodraščio vykdymo laukas: "+key); end
    end
    for key=["step" "answers" "done" "skipped" "wireMode" "wires" "journal" "wires_by_mode"]
        if ~isfield(st,key) then error("Juodraštyje trūksta LD11 būsenos: "+key); end
    end
    if ~ld11_valid_index(st.step,6) | ~ld11_valid_index(st.wireMode,2) then error("Netinkamas etapas arba režimas."); end
    if type(st.answers)<>10 | or(size(st.answers)<>[6 8]) then error("Sugadinti LD11 atsakymai."); end
    for key=["done" "skipped"]
        if type(st(key))<>4 | or(size(st(key))<>[1 6]) then error("Sugadinta etapų būsena."); end
    end
    for key=["assessment" "practice_used"]
        if isfield(st,key) then
            if type(st(key))<>4 | size(st(key),"*")<>1 then error("Netinkama režimo žyma."); end
        end
    end
    ld11_validate_saved_wires(st.wires);
    for key=["wires_by_mode" "report_wires"]
        if isfield(st,key) then
            if typeof(st(key))<>"list" then error("Sugadinti režimų laidai."); end
            if length(st(key))<>2 then error("Netinkamas režimų skaičius."); end
            groups=st(key);
            for mode=1:2; ld11_validate_saved_wires(groups(mode)); end
        end
    end
    j=st.journal;
    if j<>[] then
        if type(j)<>1 then error("Sugadintas LD11 žurnalas."); end
        if ~isreal(j) | size(j,2)<>5 | size(j,1)>2 then error("Netinkami žurnalo matmenys."); end
        if or(isnan(j)) | or(isinf(j)) | or(j<=0) then error("Netinkamos matavimų reikšmės."); end
        for k=1:size(j,1)
            if ~ld11_valid_index(j(k,3),2) | j(k,5)<>j(k,3) | sum(j(:,3)==j(k,3))<>1 then error("Pasikartojantis arba netinkamas režimas."); end
        end
    end
endfunction

function ld11_validate_saved_wires(wires)
    if wires==[] then return; end
    if type(wires)<>10 | size(wires,2)<>2 | size(wires,1)>10 then error("Sugadinti LD11 laidai."); end
    ids=ld11_terminal_ids();
    for k=1:size(wires,1)
        a=wires(k,1); b=wires(k,2);
        if ~or(ids==a) | ~or(ids==b) | a==b then error("Nežinomas arba pakartotas LD11 gnybtas."); end
        for n=1:k-1
            if and(wires(n,:)==[a b]) | and(wires(n,:)==[b a]) then error("Juodraštyje kartojasi tas pats laidas."); end
        end
        if sum(wires==a)>2 | sum(wires==b)>2 then error("LD11 gnybte gali būti iki dviejų laidų."); end
    end
endfunction
