/*
:name: test_tlm2_custom_phase_socket_relays_preserve_both_paths_and_reference_phase_updates
:description: tlm2 custom phase socket relays preserve both paths and reference phase updates (IEEE 1800.2-2020 Section 12.3.5)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.5 12.3.5.3 12.3.5.3.1 12.3.5.4 12.3.5.4.1 12.3.5.4.4 12.3.5.5 12.3.5.5.1 12.3.5.5.4 12.3.5.6 12.3.5.6.1 12.3.5.6.4 12.3.2.2.1 12.3.2.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_custom_phase_socket_relays_preserve_both_paths_and_reference_phase_updates.expected
*/
// What it checks:
// 1. Selected nonblocking relay sockets carry forward and backward calls
//    across component boundaries.
// 2. The selected initiator relay connect wires both paths for compatible
//    custom transaction/phase declarations.
// 3. The selected target relay connect wires both paths for compatible custom
//    transaction/phase declarations.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.5 (UVM-TLM2-TYPES-NONBLOCKING-HIERARCHICAL-PAIR) gives
//    rule 1 above. Setup: Connect actual nonblocking terminators through both
//    relay families across component boundaries with a custom message and
//    phase enum. Expected: Custom transaction/phase identities, reference
//    updates and shared delay mutations survive both paths.
// 2. 1800.2-2020 12.3.5.5.4 (UVM-TLM2-TYPES-INITIATOR-RELAY-CUSTOM-P) gives
//    rule 2 above. Setup: Connect actual nonblocking terminators through both
//    relay families across component boundaries with a custom message and
//    phase enum. Expected: Both actual connected relays return updated forward
//    and completed backward states through the custom enum.
// 3. 1800.2-2020 12.3.5.6.4 (UVM-TLM2-TYPES-TARGET-RELAY-CUSTOM-P) gives rule
//    3 above. Setup: Connect actual nonblocking terminators through both relay
//    families across component boundaries with a custom message and phase
//    enum. Expected: Both actual connected relays return updated forward and
//    completed backward states through the custom enum.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Actual two-way socket relays cross real component boundaries with custom
// T/P.
// The class-declaration type parameters and selected forwarding are tested;
// printed connect signatures that omit P or parameter syntax remain separately
// qualified. Original custom phases/data are setup, not the standard base
// protocol.
module test_tlm2_custom_phase_socket_relays_preserve_both_paths_and_reference_phase_updates;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  typedef enum {ISSUE,REQUEST_SEEN,REPLY,FINISH} local_phase;
  class message extends uvm_object;
    int reply = 0;
    function new(); super.new("message"); endfunction
  endclass
  class target extends uvm_component;
    uvm_tlm_nb_target_socket#(target,message,local_phase) socket;
    message expected;
    uvm_tlm_time expected_delay;
    int calls = 0;
    bit identity = 0,input_phase = 0;
    function new(string name,uvm_component parent);
      super.new(name,parent); socket = new("socket",this);
    endfunction
    function uvm_tlm_sync_e nb_transport_fw(message value,ref local_phase phase,
                                           input uvm_tlm_time delay);
      calls++; identity = value == expected && delay == expected_delay;
      input_phase = phase == ISSUE; value.reply = 37; phase = REQUEST_SEEN;
      delay.set_abstime(3.0,1.0e-9); return UVM_TLM_UPDATED;
    endfunction
  endclass
  class initiator extends uvm_component;
    uvm_tlm_nb_initiator_socket#(initiator,message,local_phase) socket;
    message expected;
    uvm_tlm_time expected_delay;
    int calls = 0;
    bit identity = 0,input_phase = 0;
    function new(string name,uvm_component parent);
      super.new(name,parent); socket = new("socket",this);
    endfunction
    function uvm_tlm_sync_e nb_transport_bw(message value,ref local_phase phase,
                                           input uvm_tlm_time delay);
      calls++; identity = value == expected && delay == expected_delay;
      input_phase = phase == REPLY; phase = FINISH;
      delay.set_abstime(9.0,1.0e-9); return UVM_TLM_COMPLETED;
    endfunction
  endclass
  class source_shell extends uvm_component;
    uvm_tlm_nb_passthrough_initiator_socket#(message,local_phase) socket;
    initiator endpoint;
    function new(string name,uvm_component parent);
      super.new(name,parent); socket = new("socket",this); endpoint = new("endpoint",this);
    endfunction
  endclass
  class target_shell extends uvm_component;
    uvm_tlm_nb_passthrough_target_socket#(message,local_phase) socket;
    target endpoint;
    function new(string name,uvm_component parent);
      super.new(name,parent); socket = new("socket",this); endpoint = new("endpoint",this);
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    source_shell source;
    target_shell destination;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); source = new("source",this); destination = new("destination",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      source.endpoint.socket.connect(source.socket); source.socket.connect(destination.socket);
      destination.socket.connect(destination.endpoint.socket);
    endfunction
    task run_phase(uvm_phase phase);
      message value = new();
      uvm_tlm_time delay = new("delay",1.0e-12);
      local_phase phase_value;
      uvm_tlm_sync_e result;
      time before_time;
      real annotation;
      phase.raise_objection(this);
      source.endpoint.expected = value; source.endpoint.expected_delay = delay;
      destination.endpoint.expected = value; destination.endpoint.expected_delay = delay;
      before_time = $time; phase_value = ISSUE;
      result = source.endpoint.socket.nb_transport_fw(value,phase_value,delay);
      $display("UT: custom_fw updated %0d phases %0d/%0d reply %0d calls %0d same %0d",
               result == UVM_TLM_UPDATED,destination.endpoint.input_phase,
      phase_value == REQUEST_SEEN,
               value.reply,destination.endpoint.calls,destination.endpoint.identity);
      phase_value = REPLY;
      result = destination.endpoint.socket.nb_transport_bw(value,phase_value,delay);
      annotation = delay.get_abstime(1.0e-9);
      $display("UT: custom_bw done %0d phases %0d/%0d calls %0d same %0d delay %0d immediate %0d",
               result == UVM_TLM_COMPLETED,source.endpoint.input_phase,phase_value == FINISH,
               source.endpoint.calls,source.endpoint.identity,
               annotation > 8.999999 && annotation < 9.000001,$time == before_time);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #60; $fatal(1,"custom socket watchdog expired"); end
endmodule
