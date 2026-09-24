// ============================================================================
// LD8 pagalbinės funkcijos: statusas, skaičių skaitymas, headless apsaugos.
// ============================================================================

function ld8_set_status(msg, kind, hint)
    global LD8;
    if argn(2) < 3 then hint = ""; end
    if argn(2) < 2 then kind = "info"; end
    if isfield(LD8, "ui") then
        if isfield(LD8.ui, "headless") then
            if LD8.ui.headless then return; end
        end
        if isfield(LD8.ui, "statusMain") & is_handle_valid(LD8.ui.statusMain) then
            LD8.ui.statusMain.string = msg;
        end
        if isfield(LD8.ui, "statusFix") & is_handle_valid(LD8.ui.statusFix) then
            LD8.ui.statusFix.string = hint;
        end
    end
endfunction

function v = ld8_parse_number(s)
    v = %nan;
    if exists("bench_safe_number") == 1 then
        v = bench_safe_number(s);
    end
endfunction

function s = ld8_trim(s)
    s = stripblanks(s);
endfunction

function ok = ld8_valid_index(value, maximum)
    ok = %f;
    if type(value) <> 1 | size(value, "*") <> 1 then return; end
    if ~isreal(value) | isnan(value) | isinf(value) then return; end
    ok = value >= 1 & value <= maximum & value == floor(value);
endfunction

// Ignore queued UI events after closing; explicit headless checks remain supported.
function active = ld8_can_act()
    global LD8;
    active=%f;
    if typeof(LD8)<>"st" then return; end
    if isfield(LD8,"ui") then
        if isfield(LD8.ui,"headless") then
            if LD8.ui.headless then active=%t; return; end
        end
    end
    if isfield(LD8,"fig") then active=is_handle_valid(LD8.fig); end
endfunction

// Validate imported local state before touching the open student's work.
function ld8_validate_snapshot(session)
    st=session.state;
    for key=["ui" "fig" "term" "root" "cfg" "student" "autosave_paths" "autosave_error"]
        if isfield(st,key) then error("Juodraštyje yra netinkamas vykdymo laukas: "+key); end
    end
    for key=["step" "answers" "done" "skipped" "wireMode" "wires" "wires_by_mode" "journal"]
        if ~isfield(st,key) then error("Juodraštyje trūksta LD8 būsenos: "+key); end
    end
    if ~ld8_valid_index(st.step,6) | ~ld8_valid_index(st.wireMode,3) then error("Netinkamas juodraščio etapas arba jungimo režimas."); end
    if type(st.answers)<>10 | or(size(st.answers)<>[6 8]) then error("Sugadinti LD8 juodraščio atsakymai."); end
    for key=["done" "skipped"]
        if type(st(key))<>4 | or(size(st(key))<>[1 6]) then error("Sugadinta LD8 etapų būsena."); end
    end
    for key=["assessment" "practice_used"]
        if isfield(st,key) then
            if type(st(key))<>4 | size(st(key),"*")<>1 then error("Sugadinta LD8 darbo režimo žyma."); end
        end
    end
    for key=["wires_by_mode" "report_wires"]
        if ~isfield(st,key) then continue; end // Old drafts may have no wiring evidence.
        if typeof(st(key))<>"list" then error("Sugadinti LD8 laidų duomenys."); end
        if length(st(key))<>3 then error("Juodraštyje turi būti trys jungimo režimai."); end
        for k=1:3; ld8_validate_saved_wires(st(key)(k)); end
    end
    ld8_validate_saved_wires(st.wires);
    j=st.journal;
    if j<>[] then
        if type(j)<>1 then error("Sugadintas LD8 matavimų žurnalas."); end
        if ~isreal(j) | size(j,2)<>5 | size(j,1)>3 then error("Netinkami LD8 matavimų žurnalo matmenys."); end
        if or(isnan(j)) | or(isinf(j)) | or(j<=0) then error("Netinkamos LD8 matavimų reikšmės."); end
        for k=1:size(j,1)
            if ~ld8_valid_index(j(k,3),3) | sum(j(:,3)==j(k,3))<>1 then error("Pasikartojantis arba netinkamas matavimo režimas."); end
        end
    end
endfunction

function ld8_validate_saved_wires(wires)
    if wires==[] then return; end
    if type(wires)<>10 | size(wires,2)<>2 | size(wires,1)>10 then error("Sugadinti LD8 laidai."); end
    ids=ld8_terminal_ids();
    for k=1:size(wires,1)
        a=wires(k,1); b=wires(k,2);
        if ~or(ids==a) | ~or(ids==b) | a==b then error("Nežinomas arba pakartotas LD8 gnybtas."); end
        for n=1:k-1
            if and(wires(n,:)==[a b]) | and(wires(n,:)==[b a]) then error("Juodraštyje kartojasi tas pats laidas."); end
        end
        if sum(wires==a)>2 | sum(wires==b)>2 then error("LD8 gnybte gali būti iki dviejų laidų."); end
    end
endfunction
