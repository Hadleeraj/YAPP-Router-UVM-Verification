class base_test extends uvm_test;
  `uvm_component_utils (base_test)
  
  router_tb tb;
  
  function new(input string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase",
                                "default_sequence",
                                yapp_5_packets::get_type());
    
    uvm_config_int::set( this, "*", "recording_detail", 1);
   
    tb = router_tb::type_id::create("tb", this);
    `uvm_info("MSG", "Test build phase executed", UVM_NONE)
    
  endfunction
  
  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology() ;
  endfunction
  
  function void check_phase(uvm_phase phase);
    check_config_usage();
  endfunction
  
  task run_phase(uvm_phase phase);
    uvm_objection obj = phase.get_objection();
    obj.set_drain_time(this, 200ns);
  endtask
endclass

class short_packet_test extends base_test;
  `uvm_component_utils(short_packet_test)
  
  function new(input string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
    super.build_phase(phase);
  endfunction
endclass

class set_config_test extends base_test;
  `uvm_component_utils(set_config_test)  
  
  function new(input string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "tb.yapp.agent", "is_active", UVM_PASSIVE);
    super.build_phase(phase);

  endfunction
endclass

class incr_payload_test extends base_test;
  `uvm_component_utils (incr_payload_test)
  
  
  function new(input string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);    
    yapp_packet::type_id::set_type_override(short_yapp_packet::get_type());
     uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase",
                                "default_sequence",
                                yapp_incr_payload_seq::get_type());
   
  endfunction  
endclass

class exhaustive_seq_test extends  base_test;
  `uvm_component_utils (exhaustive_seq_test)
  
  
  function new(input string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   yapp_packet::type_id::set_type_override(short_yapp_packet::get_type());
    
     uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase",
                                "default_sequence",
                                yapp_exhaustive_seq::get_type()); 
  endfunction
endclass
    

class new_test extends base_test;
  `uvm_component_utils (new_test)
  
  
  function new(input string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   yapp_packet::type_id::set_type_override(short_yapp_packet::get_type());
     uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase",
                                "default_sequence",
                                yapp_012_seq::get_type()); 
 
      
  endfunction  
  endclass : new_test


class simple_test extends base_test;
  `uvm_component_utils(simple_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
    uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase",
                                "default_sequence",
                                yapp_012_seq::get_type()); 
    uvm_config_wrapper::set(this, "tb.clkrst.agent.sequencer.run_phase",
                                "default_sequence",
                                clk10_rst5_seq::get_type());
    uvm_config_wrapper::set(this, "tb.channel*.rx_agent.sequencer.run_phase",
                                "default_sequence",
                                channel_rx_resp_seq::get_type()); 
  endfunction
endclass
  
class test_mc extends base_test;
  `uvm_component_utils(test_mc)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    yapp_packet::type_id::set_type_override(short_yapp_packet::get_type());
    uvm_config_wrapper::set(this, "tb.clkrst.agent.sequencer.run_phase",
                            "default_sequence", clk10_rst5_seq::type_id::get());
    
    uvm_config_wrapper::set(this, "tb.chan?.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_rx_resp_seq::type_id::get());    
  
    uvm_config_wrapper::set(this, "tb.mcsequencer.run_phase","default_sequence", router_simple_mcseq::type_id::get());
    
  endfunction
  
endclass

    
   
    
    
    
                                     
    
