class router_simple_mcseq extends uvm_sequence;
  `uvm_object_utils(router_simple_mcseq)
  `uvm_declare_p_sequencer(router_mcsequencer)
  
  
  function new(string name="router_simple_mcseq"); 
    super.new(name);
  endfunction
  
  hbus_small_packet_seq small_pkt;
  hbus_read_max_pkt_seq read_max;
  hbus_set_default_regs_seq large_pkt;
  yapp_012_seq yapp012;
  yapp_5_packets yapp6;
  
  virtual task body();
    
    if (starting_phase != null)
      starting_phase.raise_objection(this);
    
    //Set the router to accept small packets (payload length < 21) and enable it. 
    `uvm_do_on(small_pkt, p_sequencer.hbus_seqr)
    
    //Read the router MAXPKTSIZE register to make sure it has been correctly set
    `uvm_do_on(read_max, p_sequencer.hbus_seqr)
    
    //Send six consecutive YAPP packets to addresses 0, 1, 2 using yapp_012_seq.
    `uvm_do_on(yapp012, p_sequencer.yapp_seqr)
    `uvm_do_on(yapp012, p_sequencer.yapp_seqr)
    //Set the router to accept large packets (payload length < 64). 
    `uvm_do_on(large_pkt, p_sequencer.hbus_seqr)
    
    //Read the router MAXPKTSIZE register to make sure it has been correctly set. 
    `uvm_do_on(read_max, p_sequencer.hbus_seqr)
    
    //Send a random sequence of six YAPP packets. 
    `uvm_do_on(yapp6, p_sequencer.yapp_seqr)
    
    if (starting_phase != null)
      starting_phase.drop_objection(this);   
  endtask
endclass
