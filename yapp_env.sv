class yapp_env extends uvm_env;
  yapp_tx_agent agent;  
  `uvm_component_utils(yapp_env)
  
  function new(input string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = yapp_tx_agent::type_id::create("agent", this);
  endfunction
endclass

    
    
    
