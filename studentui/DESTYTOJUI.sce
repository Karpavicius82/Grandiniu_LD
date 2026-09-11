mode(-1);
teacher_root=get_absolute_file_path("DESTYTOJUI.sce");
exec(teacher_root+"bench_common.sci",-1);
exec(teacher_root+"bench_teacher.sci",-1);
bench_teacher();
