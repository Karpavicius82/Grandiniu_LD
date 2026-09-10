#!/usr/bin/env bash
set -eu
bench_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
bench_scilab=${SCILAB_BIN:-}
if [ -z "$bench_scilab" ]; then bench_scilab=$(command -v scilab || true); fi
if [ -z "$bench_scilab" ]; then
    for candidate in "$HOME"/Downloads/scilab-*/bin/scilab /tmp/scilab-clean-*/scilab-*/bin/scilab; do
        if [ -x "$candidate" ]; then bench_scilab=$candidate; break; fi
    done
fi
if [ -z "$bench_scilab" ] || [ ! -x "$bench_scilab" ]; then
    printf '%s\n' 'Scilab nerastas. Nurodykite SCILAB_BIN.' >&2
    exit 1
fi
bench_mode=${1:-visi}
case "$bench_mode" in visi|modelis|langai) ;; *) printf '%s\n' 'Naudojimas: ./PATIKRINTI.sh [visi|modelis|langai]' >&2; exit 2 ;; esac
mkdir -p "$bench_dir/tests/results"
bench_run() {
    bench_log=$1
    shift
    printf 'Vykdoma: %s\n' "$bench_log"
    if timeout 600 "$bench_scilab" "$@" > "$bench_dir/tests/results/$bench_log" 2>&1; then
        tail -n 3 "$bench_dir/tests/results/$bench_log"
    else
        bench_code=$?
        tail -n 25 "$bench_dir/tests/results/$bench_log"
        printf 'PATIKRA NEPRAĖJO (kodas %s). Žurnalas: %s\n' "$bench_code" "$bench_dir/tests/results/$bench_log" >&2
        exit "$bench_code"
    fi
}
if [ "$bench_mode" != langai ]; then bench_run modelis.log -nwni -nb -f "$bench_dir/tests/HEADLESS.sce"; fi
if [ "$bench_mode" != modelis ]; then bench_run langai.log -nw -nb -f "$bench_dir/GUI_PATIKRA.sce"; fi
printf '%s\n' 'PATIKRA BAIGTA: PASS'
