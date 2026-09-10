function ld2_event(code,detail)
    global LD2;
    if ~isfield(LD2.state,"events") then return; end
    if LD2.example_active then origin="MOKOMASIS PAVYZDYS"; else origin="STUDENTO VEIKSMAS"; end
    ev=struct("time",ld2_timestamp(),"step",LD2.state.step,"code",code,"detail",detail,"origin",origin);
    LD2.state.events($+1)=ev;
endfunction
