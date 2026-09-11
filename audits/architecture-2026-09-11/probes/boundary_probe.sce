mode(-1);
audit_here=get_absolute_file_path("boundary_probe.sce");
audit_tmp=getenv("LD_AUDIT_TMP");
try
    link(fullfile(audit_tmp,"core_probe"+getdynlibext()),"ld_mna_probe","c");
    exec(audit_here+"model_probe.sce",-1);
    link(fullfile(audit_tmp,"native_probe"+getdynlibext()),"ld_rlc_batch","c");
    n=650; data=zeros(n,6); expected=zeros(n,4);
    for k=1:n
        e=5+modulo(k,5); f=100+k; r=100+modulo(k,64); l=0.1; c=4.7d-6; kind=modulo(k,2);
        data(k,:)=[e f r l c kind]; w=2*%pi*f;
        if kind==0 then current=e/(r+%i*(w*l-1/(w*c)));
        else current=e*(1/r+%i*(w*c-1/(w*l))); end
        power=e*conj(current);
        expected(k,:)=[real(current) imag(current) real(power) imag(power)];
    end
    [out,status]=call("ld_rlc_batch",data,1,"d",n,2,"i",6,3,"i", ...
        "out",[n 4],4,"d",[n 1],5,"i");
    assert_checktrue(and(status==0));
    assert_checktrue(max(abs(out-expected))<1d-10);
    data(1,3)=-1; data(2,2)=%nan; data(3,6)=2;
    [out,status]=call("ld_rlc_batch",data,1,"d",n,2,"i",6,3,"i", ...
        "out",[n 4],4,"d",[n 1],5,"i");
    assert_checktrue(and(status(1:3)<>0)); assert_checktrue(and(status(4:$)==0));
    mprintf("SCILAB_CPP_BOUNDARY_PASS: 650 rows, real/imaginary arrays, per-row invalid input rejection.\n");
    // Harmless demonstration of the current LD1 expression parser's side effect.
    global audit_expression_executed;
    audit_expression_executed=%f;
    function value=audit_harmless_expression()
        global audit_expression_executed;
        audit_expression_executed=%t; value=7;
    endfunction
    value=ld1_parse_number("audit_harmless_expression()");
    assert_checktrue(audit_expression_executed & value==7);
    mprintf("CONFIRMED_FINDING: LD1 numeric parser executes expressions; do not use it for report import.\n");
    assert_checktrue(isnan(ld2_safe_number("audit_harmless_expression()")));
    assert_checkequal(ld2_safe_number("1,25"),1.25);
    assert_checktrue(isnan(ld2_safe_number("1e999")));
    // Exercise Unicode, missing values, row shape and hostile-looking text as data.
    payload=struct("schema_version",1,"name","Živilė Ąžuolaitė", ...
        "missing",%nan,"one",list(17),"note","</script><script>probe</script>");
    encoded=toJSON(payload);
    decoded=fromJSON(encoded);
    assert_checkequal(decoded.name,payload.name);
    assert_checktrue(isempty(decoded.missing));
    assert_checkequal(decoded.note,payload.note);
    raw=encoded;
    encoded=strsubst(encoded,"<",ascii(92)+"u003c");
    decoded=fromJSON(encoded); assert_checkequal(decoded.note,payload.note);
    assert_checkequal(size(strindex(encoded,"</script>"),"*"),0);
    path=fullfile(audit_tmp,"Živilė bandymas su tarpais.json");
    mputl(encoded,path); decoded=fromJSON(path,"file"); assert_checkequal(decoded.name,payload.name);
    mprintf("JSON_BOUNDARY_PASS: UTF-8/path spaces, explicit single-item arrays, escaped markup.\n");
    mprintf("CONFIRMED_CONTRACT: JSON null scalar decodes to []; missingness needs an explicit status.\n");
    // Synthetic submissions exported by Scilab; the Python runner independently checks them.
    folder=fullfile(audit_tmp,"reports"); mkdir(folder);
    for k=1:650
        variant=modulo(k-1,64)+1; cfg=ld2_variant_config(variant);
        rr=ld2_rc_values(cfg.E_RC,cfg.F_RC,cfg.R8,cfg.C2);
        answer=rr.I; answer_status="entered";
        if modulo(k,13)==0 then answer=answer*2; end
        if modulo(k,17)==0 then answer=%nan; answer_status="missing"; end
        // Deliberately embed an untrusted suggested grade: the reader must ignore it.
        record=struct("schema_version",1,"lab_id","PROBE-RC","lab_revision","audit-1", ...
            "bank_id","LD2-64-A-2026","variant",variant,"submission_id",msprintf("TEST-%04d",k), ...
            "student",struct("id",msprintf("STUDENT-%04d",k),"name",payload.name,"group","AUDIT"), ...
            "answer",struct("status",answer_status,"value_SI",answer,"unit","A"),"suggested_grade",10, ...
            "note",payload.note);
        data_json=strsubst(toJSON(record),"<",ascii(92)+"u003c");
        lines=["<!doctype html><meta charset="+ascii(34)+"utf-8"+ascii(34)+">"; ...
            "<p>SYNTHETIC PROBE — ne studento darbas</p>"; ...
            "<script type="+ascii(34)+"application/json"+ascii(34)+" id="+ascii(34)+"ld-data"+ascii(34)+">"; ...
            data_json;"</script>"];
        mputl(lines,fullfile(folder,msprintf("TEST-%04d.html",k)));
    end
    mprintf("SYNTHETIC_REPORT_EXPORT_PASS: 650 single-file HTML reports with JSON data.\n");
    exit(0);
catch
    mprintf("BOUNDARY_PROBE_FAIL: %s\n",strcat(lasterror()," | "));
    exit(1);
end
