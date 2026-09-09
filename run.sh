#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
: "${UVM_HOME:?Set UVM_HOME to the installed UVM 1.2 library used by Xcelium}"
mkdir -p results
xrun -Q -unbuffered -timescale 1ns/1ns -sysv -access +rw \
  -uvmnocdnsextra -uvmhome "$UVM_HOME" "$UVM_HOME/src/uvm_macros.svh" \
  -f files.f "$@" 2>&1 | tee results/latest.log
python3 check_log.py results/latest.log
