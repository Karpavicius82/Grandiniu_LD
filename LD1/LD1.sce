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
exec(base + "ld1_gui.sci", -1);
exec(base + "ld1_callbacks.sci", -1);

LD1 = struct();
LD1.base = base;
LD1.cfg = ld1_config();

ld1_start();
