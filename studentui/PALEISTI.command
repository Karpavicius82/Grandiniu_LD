#!/bin/bash
set -eu
bench_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec /bin/bash "$bench_dir/PALEISTI.sh"
