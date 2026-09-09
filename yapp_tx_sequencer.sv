class yapp_tx_sequencer extends uvm_sequencer #(yapp_packet);
  `uvm_component_utils(yapp_tx_sequencer)
  
  yapp_packet pkt;
  
  function new(input string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass


  
  
