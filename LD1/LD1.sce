// ================================================================
// LD Nr. 1. Nuolatinės srovės grandinės tyrimas
// Interaktyvi virtuali laboratorija v1.7, skirta Scilab 2025.1.
// Paleidimas: exec('LD1.sce', -1)
// ================================================================

clear LD1;
global LD1;

base = get_absolute_file_path("LD1.sce");

exec(base + "ld1_config.sci", -1);
exec(base + "ld1_utils.sci", -1);
exec(base + "ld1_circuit.sci", -1);

// GUI suskaidytas į mažesnius GitHub šaltinio failus funkcijų ribose.
exec(base + "ld1_gui_01.sci", -1);
exec(base + "ld1_gui_02.sci", -1);
exec(base + "ld1_gui_03.sci", -1);
exec(base + "ld1_gui_04.sci", -1);

// Valdymo logika suskaidyta funkcijų ribose; vykdymo tvarka išlaikyta.
exec(base + "ld1_callbacks_01.sci", -1);
exec(base + "ld1_callbacks_02.sci", -1);
exec(base + "ld1_callbacks_03.sci", -1);
exec(base + "ld1_callbacks_04.sci", -1);
exec(base + "ld1_callbacks_05.sci", -1);
exec(base + "ld1_callbacks_06.sci", -1);
exec(base + "ld1_callbacks_07.sci", -1);
exec(base + "ld1_callbacks_08.sci", -1);
exec(base + "ld1_callbacks_09.sci", -1);
exec(base + "ld1_callbacks_10.sci", -1);
exec(base + "ld1_callbacks_11.sci", -1);
exec(base + "ld1_callbacks_12.sci", -1);

LD1 = struct();
LD1.base = base;
LD1.cfg = ld1_config();

ld1_start();
