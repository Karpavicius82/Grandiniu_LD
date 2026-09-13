// Developer-only: export real visible controls, in client pixels, for C++ audit.
function geometry_walk(h,rect,path,label,fd)
    for k=1:size(h.children,"*")
        ch=h.children(k);
        if ch.type<>"uicontrol" then continue; end
        if ch.visible<>"on" then continue; end
        pp=ch.position;
        if ch.units=="normalized" then pp=pp.*[rect(3:4) rect(3:4)]; end
        rr=[rect(1:2)+pp(1:2) pp(3:4)]; name=path+"/"+string(k);
        mfprintf(fd,"%s\t%s\t%s\t%s\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\n", ...
            label,name,ch.style,ch.tag,rr(1),rr(2),rr(3),rr(4),rect(1),rect(2),rect(3),rect(4),ch.fontsize);
        geometry_walk(ch,rr,name,label,fd);
    end
endfunction

function geometry_dump(f,label,fd)
    geometry_walk(f,[0 0 f.axes_size],"fig",label,fd);
endfunction

function geometry_size(f,target)
    // Let the native window manager finish adding its decorations first.
    // Assert the actual client area, rather than only naming a target size.
    sleep(250);
    f.axes_size=target; sleep(250);
    if or(f.axes_size<>target) then f.axes_size=target; sleep(250); end
    assert_checkequal(f.axes_size,target);
endfunction
