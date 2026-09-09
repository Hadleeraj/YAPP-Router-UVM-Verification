# Verification evidence and test plan

## Recorded smoke run

- Date: 9 September 2026.
- Simulator: Xcelium 25.03-s001; Cadence UVM 1.2; default seed 1.
- Test: portfolio_smoke_test; 30 good-parity packets, ten for each destination, payload lengths randomized from 1 to 14.
- Result: 30 input packets, 30 matches, zero miscompares/unexpected packets, empty expected queues, zero UVM errors/fatals.
- One UVM warning reports deprecated get/set_config_* usage in the inherited HBUS monitor. A compile warning also flags an ignored function return in yapp_tx_agent.sv.
- Simulation finished at 6925 ns. Two HBUS writes configured maximum length and enable; this run did not check register readback.
- The smoke classes were compiled inline inside the playground testbench for validation. The repository places identical class code in portfolio_smoke_test.sv and includes it from portfolio_testbench.sv. files.f lists only design.sv and that portfolio top.

The log under results is an excerpt of the measured run, not a new run or a coverage report. run.sh is the local command adaptation; its execution on an external simulator installation has not been tested here.

## Debug findings

1. The original short_packet_test raises a stimulus objection without starting the clock/reset sequence. The observed run reached the playground runtime limit (exit 137), not successful completion.
2. Selecting simple_test starts clocks and receiver sequences. Its observed run left one expected packet in each scoreboard queue and reported one UVM error, despite a later TEST PASSED message.
3. The receive driver deasserted suspend immediately after reset, allowing FIFO reads before a response sequence was ready. Holding suspend high until send_response releases it restored alignment. The final 30-packet smoke passed with this correction and the original channel_if sampling logic.
4. The added smoke explicitly programs HBUS configuration; absence of those writes alone was not established as the cause of the original simple_test failure.

## Acceptance criteria

Use check_log.py on the complete log. Require zero UVM errors/fatals, the explicit SMOKE_COUNTS result, ten matches on each output, and empty queues. Inspect simulator exit status and warnings too. A TEST PASSED line by itself is insufficient.

## Verification plan

| Feature | Current evidence | Next regression |
|---|---|---|
| Routing to outputs 0/1/2 | Ten matches per output | Random destination stress and ordering |
| Short payload transport | Random lengths 1–14 in smoke | Directed min/max and full 1–63 length range |
| Valid parity | Generated and transported in smoke | Error indication, bad parity and expected-drop policy |
| HBUS configuration | Two writes | Readback assertions and register adapter integration |
| Backpressure | Existing randomized response delays | Sustained stalls, FIFO full/empty and recovery |
| Reset | Startup sequence | Reset while traffic is in flight |
| Scoreboard integrity | Cloned expectations and per-output queues | Negative tests, drop accounting and report cleanup |
| Coverage | Covergroups present | Explicit coverage reports and justified closure targets |

The inherited test_mc uses a channel wildcard that does not match the channel0/channel1/channel2 instance names. Review original example configurations before using them as regressions. The virtual sequence named router_simple_mcseq invokes yapp_5_packets, so its final burst is five packets even though a comment says six.
