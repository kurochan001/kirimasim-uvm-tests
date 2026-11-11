/*
:name: test_tlm2_same_kind_terminator_socket_connections_leave_no_provider_bindings
:description: qualified no-binding interpretation after same-kind terminator connects (IEEE 1800.2-2020 Section 12.3.5)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.5 5.5.2.9 5.5.2.14 12.3.5.1.4 12.3.5.3.4 12.3.5.2.4 12.3.5.4.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_same_kind_terminator_socket_connections_leave_no_provider_bindings.expected
*/
// What it checks:
// 1. Under a no-binding interpretation, a initiator terminator cannot connect
//    to another initiator terminator.
// 2. Under a no-binding interpretation, a target terminator cannot connect to
//    another target terminator.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.5 (UVM-TLM2-TYPES-SAME-KIND-INITIATOR-REJECTION) gives
//    rule 1 above. Setup: Attempt same-kind terminator connects in blocking
//    and nonblocking families, then query each direct provider list. Expected:
//    Both selected blocking and nonblocking same-kind connects leave no direct
//    provider binding.
// 2. 1800.2-2020 12.3.5 (UVM-TLM2-TYPES-SAME-KIND-TARGET-REJECTION) gives rule
//    2 above. Setup: Attempt same-kind terminator connects in blocking and
//    nonblocking families, then query each direct provider list. Expected:
//    Both selected blocking and nonblocking same-kind connects leave no direct
//    provider binding.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Attempt same-kind terminator connects, then query direct provider entries.
// This is a qualified no-binding interpretation of the general restriction.
// The standard does not specify direct-list state after an invalid call.
// Preserve any residual entry for review; it is not a proven socket defect.
// No report severity, resolved binding or attempted transaction is inferred.
module test_tlm2_same_kind_terminator_socket_connections_leave_no_provider_bindings;
  import uvm_pkg::*;
  class endpoint extends uvm_component;
    function new(); super.new("owner",null); endfunction
    task b_transport(uvm_tlm_generic_payload value,uvm_tlm_time delay); endtask
    function uvm_tlm_sync_e nb_transport_fw(uvm_tlm_generic_payload value,
        ref uvm_tlm_phase_e phase,input uvm_tlm_time delay); return UVM_TLM_COMPLETED; endfunction
    function uvm_tlm_sync_e nb_transport_bw(uvm_tlm_generic_payload value,
        ref uvm_tlm_phase_e phase,input uvm_tlm_time delay); return UVM_TLM_COMPLETED; endfunction
  endclass
  initial begin
    automatic endpoint owner = new();
    automatic uvm_tlm_b_initiator_socket#() bi0 = new("bi0",owner);
    automatic uvm_tlm_b_initiator_socket#() bi1 = new("bi1",owner);
    automatic uvm_tlm_b_target_socket#(endpoint) bt0 = new("bt0",owner);
    automatic uvm_tlm_b_target_socket#(endpoint) bt1 = new("bt1",owner);
    automatic uvm_tlm_nb_initiator_socket#(endpoint) ni0 = new("ni0",owner);
    automatic uvm_tlm_nb_initiator_socket#(endpoint) ni1 = new("ni1",owner);
    automatic uvm_tlm_nb_target_socket#(endpoint) nt0 = new("nt0",owner);
    automatic uvm_tlm_nb_target_socket#(endpoint) nt1 = new("nt1",owner);
    uvm_port_base#(uvm_tlm_if#(uvm_tlm_generic_payload,uvm_tlm_phase_e)) connections[string];
    bit bi_rejected,bt_rejected,ni_rejected,nt_rejected;
    bi0.connect(bi1); bi0.get_connected_to(connections); bi_rejected = connections.num() == 0;
    connections.delete();
    bt0.connect(bt1); bt0.get_connected_to(connections); bt_rejected = connections.num() == 0;
    connections.delete();
    ni0.connect(ni1); ni0.get_connected_to(connections); ni_rejected = connections.num() == 0;
    connections.delete();
    nt0.connect(nt1); nt0.get_connected_to(connections); nt_rejected = connections.num() == 0;
    $display("UT: same_kind_terminators blocking %0d/%0d nonblocking %0d/%0d",
             bi_rejected,bt_rejected,ni_rejected,nt_rejected);
    $finish;
  end
endmodule
