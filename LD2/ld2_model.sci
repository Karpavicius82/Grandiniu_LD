// ============================================================================
// LD2 elektrinis modelis. Naudojamos teisingos kompleksinių dydžių formulės.
// Visi įtampos ir srovės dydžiai yra RMS.
// ============================================================================

function r = ld2_rc_values(E, f, R, C)
    if f <= 0 | R <= 0 | C <= 0 then
        r = struct("X", %inf, "Z", %inf, "I", 0.0, "UR", 0.0, ...
                   "UX", E, "P", 0.0, "PHI_Z", -90.0, "PHI_I", 90.0);
        return;
    end
    Xc = 1.0 / (2.0 * %pi * f * C);
    Zm = sqrt(R^2 + Xc^2);
    I = E / Zm;
    UR = I * R;
    UC = I * Xc;
    phi = atan(Xc / R) * 180.0 / %pi;
    r = struct("X", Xc, "Z", Zm, "I", I, "UR", UR, "UX", UC, ...
               "P", I^2 * R, "PHI_Z", -phi, "PHI_I", phi);
endfunction

function r = ld2_rl_values(E, f, R, L)
    if f < 0 | R <= 0 | L <= 0 then
        r = struct("X", 0.0, "Z", R, "I", E/R, "UR", E, ...
                   "UX", 0.0, "P", E^2/R, "PHI_Z", 0.0, "PHI_I", 0.0);
        return;
    end
    Xl = 2.0 * %pi * f * L;
    Zm = sqrt(R^2 + Xl^2);
    I = E / Zm;
    UR = I * R;
    UL = I * Xl;
    phi = atan(Xl / R) * 180.0 / %pi;
    r = struct("X", Xl, "Z", Zm, "I", I, "UR", UR, "UX", UL, ...
               "P", I^2 * R, "PHI_Z", phi, "PHI_I", -phi);
endfunction

function r = ld2_rlc_values(E, f, R, L, C)
    if R <= 0 | L <= 0 | C <= 0 then
        error("R, L ir C turi būti teigiami.");
    end
    if f <= 0 then
        r = struct("XL", 0.0, "XC", %inf, "Z", %inf, "I", 0.0, ...
                   "UR", 0.0, "UL", 0.0, "UC", E, "ULC", E, ...
                   "P", 0.0, "PHI", -90.0);
        return;
    end
    w = 2.0 * %pi * f;
    Xl = w * L;
    Xc = 1.0 / (w * C);
    X = Xl - Xc;
    Zm = sqrt(R^2 + X^2);
    I = E / Zm;
    UR = I * R;
    UL = I * Xl;
    UC = I * Xc;
    phi = atan(X / R) * 180.0 / %pi;
    r = struct("XL", Xl, "XC", Xc, "Z", Zm, "I", I, ...
               "UR", UR, "UL", UL, "UC", UC, "ULC", abs(UL-UC), ...
               "P", I^2 * R, "PHI", phi);
endfunction

function rr = ld2_resonance_values(R, L, C)
    if R <= 0 | L <= 0 | C <= 0 then
        error("R, L ir C turi būti teigiami.");
    end
    w0 = 1.0 / sqrt(L * C);
    f0 = w0 / (2.0 * %pi);
    disc = sqrt(R^2 + 4.0 * L / C);
    w1 = (-R + disc) / (2.0 * L);
    w2 = ( R + disc) / (2.0 * L);
    f1 = w1 / (2.0 * %pi);
    f2 = w2 / (2.0 * %pi);
    bw = f2 - f1;
    q = w0 * L / R;
    rr = struct("F0", f0, "F1", f1, "F2", f2, "BW", bw, "Q", q, ...
                "W0", w0);
endfunction

function y = ld2_relative_error(a, b)
    if abs(b) < 1d-15 then
        y = abs(a-b);
    else
        y = abs(a-b) / abs(b);
    end
endfunction

function ok = ld2_close_enough(user_value, reference_value)
    global LD2;
    ok = abs(user_value-reference_value) <= LD2.cfg.ANSWER_TOL_ABS + ...
         LD2.cfg.ANSWER_TOL_REL * abs(reference_value);
endfunction

function [f, ur, ii] = ld2_frequency_sweep(E, R, L, C, fmax)
    f = (0:1000:fmax)';
    n = size(f, "*");
    ur = zeros(n,1);
    ii = zeros(n,1);
    for k = 1:n
        r = ld2_rlc_values(E, f(k), R, L, C);
        ur(k) = r.UR;
        ii(k) = r.I;
    end
endfunction

function [f, ur] = ld2_dense_resonance_curve(E, R, L, C, fmax)
    n = 801;
    f = linspace(max(1.0, fmax/1000.0), fmax, n)';
    ur = zeros(n,1);
    for k = 1:n
        r = ld2_rlc_values(E, f(k), R, L, C);
        ur(k) = r.UR;
    end
endfunction
