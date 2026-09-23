#!/usr/bin/env bash
set -eu
bench_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
bench_scilab=${SCILAB_BIN:-}
if [ -z "$bench_scilab" ]; then
    if [ "$(uname -s)" = Darwin ]; then
        for app in /Applications/*[Ss]cilab*.app "$HOME"/Applications/*[Ss]cilab*.app; do
            [ -d "$app/Contents" ] || continue
            candidate=$(find "$app/Contents" -type f -name scilab -print -quit)
            if [ -n "$candidate" ] && [ -x "$candidate" ]; then bench_scilab=$candidate; break; fi
        done
    fi
fi
if [ -z "$bench_scilab" ]; then
    bench_scilab=$(command -v scilab || true)
fi
if [ -z "$bench_scilab" ]; then
    for candidate in "$HOME"/Downloads/scilab-*/bin/scilab /tmp/scilab-clean-*/scilab-*/bin/scilab; do
        if [ -x "$candidate" ]; then bench_scilab=$candidate; break; fi
    done
fi
if [ -z "$bench_scilab" ] || [ ! -x "$bench_scilab" ]; then
    printf '%s\n' 'Scilab nerastas. Atverkite STENDAS.sce per Scilab arba nurodykite SCILAB_BIN.' >&2
    exit 1
fi
exec "$bench_scilab" -f "$bench_dir/STENDAS.sce"
