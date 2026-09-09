class router_tb extends uvm_env;
  `uvm_component_utils (router_tb)
  
  yapp_env yapp;
  hbus_env hbus;
  clock_and_reset_env clkrst;
  channel_env channel0;
  channel_env channel1;
  channel_env channel2;
  
  router_mcsequencer mcsequencer;
  router_scoreboard router_sb;
  
  
  function new(input string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_int::set(this, "channel0", "channel_id", 0);
    uvm_config_int::set(this, "channel1", "channel_id", 1);
    uvm_config_int::set(this, "channel2", "channel_id", 2);
    uvm_config_int::set(this, "hbus", "num_masters", 1);
    uvm_config_int::set(this, "hbus", "num_slaves", 0);
    yapp = yapp_env::type_id::create("yapp", this);
    hbus = hbus_env::type_id::create("hbus", this);
    clkrst = clock_and_reset_env::type_id::create("clkrst", this);
    channel0 = channel_env::type_id::create("channel0", this);
    channel1 = channel_env::type_id::create("channel1", this);
    channel2 = channel_env::type_id::create("channel2", this);
    mcsequencer = router_mcsequencer::type_id::create("mcsequencer", this);
    router_sb = router_scoreboard::type_id::create("router_sb", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    mcsequencer.hbus_seqr = hbus.masters[0].sequencer;
    mcsequencer.yapp_seqr = yapp.agent.sequencer;
    
    //Connect TLM ports from the YAPP and Channel UVC to the scoreboard
    yapp.agent.monitor.item_collected_port.connect(router_sb.sb_yapp_in);
    channel0.rx_agent.monitor.item_collected_port.connect(router_sb.sb_chan0);
    channel1.rx_agent.monitor.item_collected_port.connect(router_sb.sb_chan1);
    channel2.rx_agent.monitor.item_collected_port.connect(router_sb.sb_chan2);
    
  endfunction    
  
  
endclass
  
               
    
  
  
    
