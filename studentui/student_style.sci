// Shared native Scilab styling for both student benches.
function h=student_text(p,pos,txt,fs,bold,bg)
    if argn(2)<6 then bg=[1 1 1]; end
    if size(strindex(txt,ascii(10)),"*")>0 then txt="<html>"+strsubst(txt,ascii(10),"<br>")+"</html>"; end
    h=uicontrol(p,"style","text","units","normalized","position",pos, ...
        "string",strsubst(txt,ascii(10),"<br>"),"fontname","DejaVu Sans","fontunits","pixels","fontsize",fs, ...
        "horizontalalignment","left","verticalalignment","middle", ...
        "backgroundcolor",bg,"foregroundcolor",[0.13 0.19 0.23]);
    if bold then h.fontweight="bold"; end
endfunction

function h=student_button(p,pos,txt,cb,primary)
    if argn(2)<5 then primary=%f; end
    bg=[0.94 0.96 0.96]; fg=[0.12 0.25 0.28];
    if primary then bg=[0.08 0.39 0.37]; fg=[1 1 1]; end
    h=uicontrol(p,"style","pushbutton","units","normalized","position",pos, ...
        "string",txt,"callback",cb,"fontname","DejaVu Sans","fontunits","pixels", ...
        "fontsize",14,"fontweight","bold","margins",[0 0 0 0],"backgroundcolor",bg,"foregroundcolor",fg);
endfunction

function h=student_frame(p,pos,bg)
    if argn(2)<3 then bg=[1 1 1]; end
    h=uicontrol(p,"style","frame","units","normalized","position",pos, ...
        "backgroundcolor",bg,"relief","flat");
endfunction

function txt=student_wrap(lines,width)
    out=emptystr(0,1);
    for line=matrix(lines,1,-1)
        words=tokens(line," "); current="";
        for k=1:size(words,"*")
            if length(current)+length(words(k))+1>width & current<>"" then
                out($+1,1)=current; current="";
            end
            if current<>"" then current=current+" "; end
            current=current+words(k);
        end
        out($+1,1)=current;
    end
    txt="<html>"+strcat(out,"<br>")+"</html>";
endfunction
