// =================================================================
//  Compilation order matters here:
//   1) UVC packages  -> they define the env classes & vif typedefs
//   2) Interfaces    -> they import the packages (enum/typedef types)
//   3) hw_top        -> instantiates the interfaces + clock gen
//  The package's "virtual <if>" typedef is a forward reference that
//  SystemVerilog resolves at elaboration, so packages can come first.
// =================================================================

// include the UVM macros (needed by the packages below)
`include "uvm_macros.svh"
import uvm_pkg::*;

// ---- 1) UVC package files (so the packages actually get compiled) ----
`include "yapp_pkg.sv"
`include "hbus_pkg.sv"
`include "channel_pkg.sv"
`include "clock_and_reset_pkg.sv"

// ---- 2) Interface files (these import the packages above) ----
`include "yapp_if.sv"
`include "hbus_if.sv"
`include "channel_if.sv"
`include "clock_and_reset_if.sv"

// ---- 3) Hardware top module (instantiates the interfaces) ----
`include "hw_top1.sv"

module tb_top;

  // import the UVC packages
  import yapp_pkg::*;
  import hbus_pkg::*;
  import channel_pkg::*;
  import clock_and_reset_pkg::*;
  `include "router_mcsequencer.sv"
  `include "router_mcseqs_lib.sv"
  `include "router_scoreboard.sv"

  // include the router testbench env and the test library
  `include "router_tb.sv"
  `include "router_test_lib.sv"

  // instantiate the hardware top
  hw_top hw_top();

  initial begin
    yapp_vif_config::set(null,"*.tb.yapp.*","vif", hw_top.in0);
    hbus_vif_config::set(null,"*.tb.hbus.*","vif", hw_top.hif);
    channel_vif_config::set(null,"*.tb.channel0.*","vif", hw_top.ch0);
    channel_vif_config::set(null,"*.tb.channel1.*","vif", hw_top.ch1);
    channel_vif_config::set(null,"*.tb.channel2.*","vif", hw_top.ch2);
    clock_and_reset_vif_config::set(null, "*.tb.clkrst.*", "vif", hw_top.clk_rst_if);

    run_test("short_packet_test");
  end

endmodule
