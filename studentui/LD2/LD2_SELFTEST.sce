// Execute in Scilab 2025.1. No GUI is opened or closed by this test.
mode(-1);
LD2_TEST_ROOT=get_absolute_file_path("LD2_SELFTEST.sce");
exec(LD2_TEST_ROOT+"LD2_LOAD.sce",-1);
[LD2_TEST_OK,LD2_TEST_LOG]=ld2_selftest();
disp(LD2_TEST_LOG);
try mputl(LD2_TEST_LOG,LD2_TEST_ROOT+"LD2_SELFTEST_LAST.txt");
catch mprintf("Negalima įrašyti testo žurnalo šalia programos. Rezultatas konsolėje.\n"); end
if ~LD2_TEST_OK then error("LD2 savikontrolė: FAIL. Žr. LD2_SELFTEST_LAST.txt."); end
