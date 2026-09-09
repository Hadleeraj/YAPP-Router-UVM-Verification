class router_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(router_scoreboard)

  // TLM port declarations
  `uvm_analysis_imp_decl(_yapp)
  `uvm_analysis_imp_decl(_chan0)
  `uvm_analysis_imp_decl(_chan1)
  `uvm_analysis_imp_decl(_chan2)

  uvm_analysis_imp_yapp  #(yapp_packet, router_scoreboard) sb_yapp_in;
  uvm_analysis_imp_chan0 #(channel_packet, router_scoreboard) sb_chan0;
  uvm_analysis_imp_chan1 #(channel_packet, router_scoreboard) sb_chan1;
  uvm_analysis_imp_chan2 #(channel_packet, router_scoreboard) sb_chan2;

  yapp_packet sb_queue0[$];
  yapp_packet sb_queue1[$];
  yapp_packet sb_queue2[$];

  // stats
  int packets_in, in_dropped;
  int packets_ch0, packets_ch1, packets_ch2;
  int compare_ch0, compare_ch1, compare_ch2;
  int miscompare_ch0, miscompare_ch1, miscompare_ch2;
  int dropped_ch0, dropped_ch1, dropped_ch2;

  typedef enum {EQUAL, UVM} compare_policy_e;
  compare_policy_e compare_policy = EQUAL;

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
    sb_yapp_in = new("sb_yapp_in", this);
    sb_chan0   = new("sb_chan0", this);
    sb_chan1   = new("sb_chan1", this);
    sb_chan2   = new("sb_chan2", this);
  endfunction

  function bit comp_equal(input yapp_packet yp, input channel_packet cp);
    if (yp.addr != cp.addr) begin
      `uvm_error("PKT_COMPARE", $sformatf("Address mismatch YAPP %0d Chan %0d", yp.addr, cp.addr))
      return 0;
    end
    if (yp.length != cp.length) begin
      `uvm_error("PKT_COMPARE", $sformatf("Length mismatch YAPP %0d Chan %0d", yp.length, cp.length))
      return 0;
    end
    foreach (yp.payload[i])
      if (yp.payload[i] != cp.payload[i]) begin
        `uvm_error("PKT_COMPARE", $sformatf("Payload[%0d] mismatch YAPP %0d Chan %0d", i, yp.payload[i], cp.payload[i]))
        return 0;
      end
    if (yp.parity != cp.parity) begin
      `uvm_error("PKT_COMPARE", $sformatf("Parity mismatch YAPP %0d Chan %0d", yp.parity, cp.parity))
      return 0;
    end
    return 1;
  endfunction

  // NOTE: stub — fill in with real field-by-field or uvm_object::compare() logic
  // once channel_packet's field layout vs yapp_packet is confirmed
  function bit comp_uvm(input yapp_packet yp, input channel_packet cp);
    return comp_equal(yp, cp);
  endfunction

  virtual function void write_yapp(yapp_packet packet);
    yapp_packet sb_packet;
    $cast(sb_packet, packet.clone());
    packets_in++;
    case (sb_packet.addr)
      2'b00: begin
        sb_queue0.push_back(sb_packet);
        `uvm_info(get_type_name(), "Added packet to Scoreboard Queue 0", UVM_HIGH)
      end
      2'b01: begin
        sb_queue1.push_back(sb_packet);
        `uvm_info(get_type_name(), "Added packet to Scoreboard Queue 1", UVM_HIGH)
      end
      2'b10: begin
        sb_queue2.push_back(sb_packet);
        `uvm_info(get_type_name(), "Added packet to Scoreboard Queue 2", UVM_HIGH)
      end
      default: begin
        `uvm_info(get_type_name(), $sformatf("Packet Dropped: Bad Address=%0d\n%s", sb_packet.addr, sb_packet.sprint()), UVM_LOW)
        in_dropped++;
      end
    endcase
  endfunction

  virtual function void write_chan0(channel_packet packet);
    bit pktcompare;
    yapp_packet sb_packet;
    packets_ch0++;

    if (sb_queue0.size() == 0) begin
      `uvm_error(get_type_name(), $sformatf("Scoreboard Error [EMPTY]: Received Unexpected Channel_0 Packet!\n%s", packet.sprint()))
      dropped_ch0++;
      return;
    end

    pktcompare = (compare_policy == UVM) ? comp_uvm(sb_queue0[0], packet) : comp_equal(sb_queue0[0], packet);

    if (pktcompare) begin
      void'(sb_queue0.pop_front());
      `uvm_info(get_type_name(), $sformatf("Scoreboard Compare Match: Channel_0 Packet\n%s", packet.sprint()), UVM_MEDIUM)
      compare_ch0++;
    end
    else begin
      sb_packet = sb_queue0[0];
      `uvm_warning(get_type_name(), $sformatf("Scoreboard Error [MISCOMPARE]: Channel_0\nExpected:\n%s\nActual:\n%s", sb_packet.sprint(), packet.sprint()))
      miscompare_ch0++;
    end
  endfunction

  virtual function void write_chan1(channel_packet packet);
    bit pktcompare;
    yapp_packet sb_packet;
    packets_ch1++;

    if (sb_queue1.size() == 0) begin
      `uvm_error(get_type_name(), $sformatf("Scoreboard Error [EMPTY]: Received Unexpected Channel_1 Packet!\n%s", packet.sprint()))
      dropped_ch1++;
      return;
    end

    pktcompare = (compare_policy == UVM) ? comp_uvm(sb_queue1[0], packet) : comp_equal(sb_queue1[0], packet);

    if (pktcompare) begin
      void'(sb_queue1.pop_front());
      `uvm_info(get_type_name(), $sformatf("Scoreboard Compare Match: Channel_1 Packet\n%s", packet.sprint()), UVM_MEDIUM)
      compare_ch1++;
    end
    else begin
      sb_packet = sb_queue1[0];
      `uvm_warning(get_type_name(), $sformatf("Scoreboard Error [MISCOMPARE]: Channel_1\nExpected:\n%s\nActual:\n%s", sb_packet.sprint(), packet.sprint()))
      miscompare_ch1++;
    end
  endfunction

  virtual function void write_chan2(channel_packet packet);
    bit pktcompare;
    yapp_packet sb_packet;
    packets_ch2++;

    if (sb_queue2.size() == 0) begin
      `uvm_error(get_type_name(), $sformatf("Scoreboard Error [EMPTY]: Received Unexpected Channel_2 Packet!\n%s", packet.sprint()))
      dropped_ch2++;
      return;
    end

    pktcompare = (compare_policy == UVM) ? comp_uvm(sb_queue2[0], packet) : comp_equal(sb_queue2[0], packet);

    if (pktcompare) begin
      void'(sb_queue2.pop_front());
      `uvm_info(get_type_name(), $sformatf("Scoreboard Compare Match: Channel_2 Packet\n%s", packet.sprint()), UVM_MEDIUM)
      compare_ch2++;
    end
    else begin
      sb_packet = sb_queue2[0];
      `uvm_warning(get_type_name(), $sformatf("Scoreboard Error [MISCOMPARE]: Channel_2\nExpected:\n%s\nActual:\n%s", sb_packet.sprint(), packet.sprint()))
      miscompare_ch2++;
    end
  endfunction

  function void check_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Checking Router Scoreboard", UVM_LOW)
    if (sb_queue0.size() || sb_queue1.size() || sb_queue2.size())
      `uvm_error(get_type_name(), $sformatf("Check: \n\n WARNING: Router scoreboard queue not empty:\n Chan0: %0d\n Chan1: %0d\n Chan2: %0d\n",
                  sb_queue0.size(), sb_queue1.size(), sb_queue2.size()))
    else
      `uvm_info(get_type_name(), "UVM Scoreboard empty! \n", UVM_LOW)
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "===== Router Scoreboard Report =====", UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Packets received from YAPP monitor : %0d", packets_in), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Packets dropped (bad address)      : %0d", in_dropped), UVM_LOW)

    `uvm_info(get_type_name(), $sformatf("Channel 0 -> received:%0d matched:%0d miscompared:%0d unexpected:%0d",
                packets_ch0, compare_ch0, miscompare_ch0, dropped_ch0), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Channel 1 -> received:%0d matched:%0d miscompared:%0d unexpected:%0d",
                packets_ch1, compare_ch1, miscompare_ch1, dropped_ch1), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Channel 2 -> received:%0d matched:%0d miscompared:%0d unexpected:%0d",
                packets_ch2, compare_ch2, miscompare_ch2, dropped_ch2), UVM_LOW)

    if (miscompare_ch0 || miscompare_ch1 || miscompare_ch2 ||
        dropped_ch0 || dropped_ch1 || dropped_ch2)
      `uvm_error(get_type_name(), "TEST FAILED: miscompares or unexpected packets detected")
    else if (packets_in == 0)
      `uvm_warning(get_type_name(), "No packets were checked - test may not be exercising the DUT")
    else
      `uvm_info(get_type_name(), "TEST PASSED: all packets matched, no drops", UVM_LOW)
  endfunction

endclass
