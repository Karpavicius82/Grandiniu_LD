#!/usr/bin/env bash
set -eu
bench_repo=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec "$bench_repo/studentui/PALEISTI.sh" "$@"
