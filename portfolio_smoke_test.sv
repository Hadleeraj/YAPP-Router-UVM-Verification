// Portfolio smoke regression: explicit initialization and completion checks.
class portfolio_packet_seq extends yapp_base_seq;
  `uvm_object_utils(portfolio_packet_seq)
  function new(string name="portfolio_packet_seq"); super.new(name); endfunction
  task body();
    for (int i=0; i<30; i++) begin
      req = yapp_packet::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {addr == local::i % 3; length inside {[1:14]}; parity_type == yapp_pkg::GOOD_PARITY;})
        `uvm_fatal("RANDOMIZE", "Packet randomization failed")
      finish_item(req);
    end
  endtask
endclass

class portfolio_smoke_test extends uvm_test;
  `uvm_component_utils(portfolio_smoke_test)
  router_tb tb;
  virtual yapp_if vif;
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_wrapper::set(this,"tb.clkrst.agent.sequencer.run_phase","default_sequence",clk10_rst5_seq::get_type());
    uvm_config_wrapper::set(this,"tb.channel*.rx_agent.sequencer.run_phase","default_sequence",channel_rx_resp_seq::get_type());
    tb=router_tb::type_id::create("tb",this);
    if (!yapp_vif_config::get(this,"tb.yapp.agent","vif",vif))
      `uvm_fatal("NOVIF","YAPP interface not configured")
  endfunction
  task run_phase(uvm_phase phase);
    hbus_set_default_regs_seq init_regs;
    portfolio_packet_seq traffic;
    phase.raise_objection(this);
    fork
      begin
        #100us;
        `uvm_fatal("TIMEOUT","Smoke test did not complete in 100 us")
      end
      begin
        @(posedge vif.reset);
        @(negedge vif.reset);
        init_regs=hbus_set_default_regs_seq::type_id::create("init_regs");
        init_regs.start(tb.hbus.masters[0].sequencer);
        traffic=portfolio_packet_seq::type_id::create("traffic");
        traffic.start(tb.yapp.agent.sequencer);
        wait(tb.router_sb.compare_ch0+tb.router_sb.compare_ch1+tb.router_sb.compare_ch2 == 30);
        #200ns;
      end
    join_any
    disable fork;
    phase.drop_objection(this);
  endtask
  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (tb.router_sb.packets_in != 30 || tb.router_sb.compare_ch0 != 10 ||
        tb.router_sb.compare_ch1 != 10 || tb.router_sb.compare_ch2 != 10 ||
        tb.router_sb.sb_queue0.size() || tb.router_sb.sb_queue1.size() || tb.router_sb.sb_queue2.size())
      `uvm_error("SMOKE_COUNTS","Expected 30 input packets, ten matches per channel, and empty queues")
    else
      `uvm_info("SMOKE_COUNTS","30 input packets matched: 10 per output channel; queues empty",UVM_LOW)
  endfunction
endclass
