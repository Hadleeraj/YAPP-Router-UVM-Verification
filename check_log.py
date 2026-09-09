#!/usr/bin/env python3
"""Validate the portfolio smoke log; a TEST PASSED string alone is insufficient."""
import re
import sys
from pathlib import Path

text = Path(sys.argv[1] if len(sys.argv) > 1 else "results/latest.log").read_text(errors="replace")
problems = []
for severity in ("UVM_ERROR", "UVM_FATAL"):
    counts = re.findall(r"(?m)^" + severity + r"\s*:\s*(\d+)\s*$", text)
    if not counts or int(counts[-1]) != 0:
        problems.append(severity + " summary missing or nonzero")
if "[SMOKE_COUNTS] 30 input packets matched: 10 per output channel; queues empty" not in text:
    problems.append("explicit smoke completion check missing")
for channel in range(3):
    expected = f"Channel {channel} -> received:10 matched:10 miscompared:0 unexpected:0"
    if expected not in text:
        problems.append(f"channel {channel} completion report missing")
if problems:
    print("FAIL: " + "; ".join(problems))
    sys.exit(1)
print("PASS: 30 packets matched, ten per output, with zero UVM errors/fatals")
