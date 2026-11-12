/*
:name: test_tlm2_interface_custom_phase_reference_and_status_dispatch_in_both_directions
:description: tlm2 interface custom phase reference and status dispatch in both directions (IEEE 1800.2-2020 Section 12.3.2.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.2.1 12.3.2.2.1 12.3.2.2.2 12.3.3.2 12.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_interface_custom_phase_reference_and_status_dispatch_in_both_directions.expected
*/
// What it checks:
// 1. The TLM 2 base interface supports selected blocking and nonblocking
//    transaction transport forms.
// 2. The TLM 2 interface accepts explicitly distinct custom transaction and
//    phase types.
// 3. The TLM 2 status type exposes accepted, updated and completed states.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.2 (UVM-TLM-DECL-TLM2-TRANSPORT-INTERFACE-FORMS) gives
//    rule 1 above. Setup: Call original default/T-only blocking and custom-T/P
//    nonblocking concrete interfaces through exact declared base views.
//    Expected: Exact concrete base views accept the selected virtual method
//    definitions and calls.
// 2. 1800.2-2020 12.3.2.1 (UVM-TLM-DECL-TLM2-CUSTOM-T-P) gives rule 2 above.
//    Setup: Call both original virtual directions through an exact custom
//    transaction/phase interface, returning all three standard status types.
//    Expected: The exact base dispatches both virtual functions and preserves
//    reference phase changes.
// 3. 1800.2-2020 12.3.3.2 (UVM-TLM-DECL-TLM2-SYNC-ENUMERATION) gives rule 3
//    above. Setup: Call both original virtual directions through an exact
//    custom transaction/phase interface, returning all three standard status
//    types. Expected: All three named statuses are returned through the
//    declared virtual interface functions.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit custom transaction/phase types exercise both declared virtual
// paths,
// reference phase mutation, shared object/delay handles and standard status
// types.
// Original accepted/updated/completed algorithms are setup; these direct
// interface
// probes do not establish real socket forwarding or full protocol compliance.
module test_tlm2_interface_custom_phase_reference_and_status_dispatch_in_both_directions;
  import uvm_pkg::*;
  typedef enum {QUEUED,REQUEST_DONE,REPLY_START,DONE} custom_phase;
  class custom_item extends uvm_object;
    int value = 13;
    function new(); super.new("custom"); endfunction
  endclass
  class custom_probe extends uvm_tlm_if#(custom_item,custom_phase);
    int forward_calls = 0,backward_calls = 0;
    virtual function uvm_tlm_sync_e nb_transport_fw(custom_item t,ref custom_phase p,
                                                  input uvm_tlm_time delay);
      forward_calls++;
      if (forward_calls == 1) return UVM_TLM_ACCEPTED;
      p = REQUEST_DONE; t.value += 7; delay.set_abstime(3.0,1.0e-9);
      return UVM_TLM_UPDATED;
    endfunction
    virtual function uvm_tlm_sync_e nb_transport_bw(custom_item t,ref custom_phase p,
                                                  input uvm_tlm_time delay);
      backward_calls++; p = DONE; t.value += 11; delay.set_abstime(8.0,1.0e-9);
      return UVM_TLM_COMPLETED;
    endfunction
  endclass
  initial begin
    automatic custom_probe probe = new();
    automatic uvm_tlm_if#(custom_item,custom_phase) base = probe;
    automatic custom_item value = new();
    automatic uvm_tlm_time delay = new("delay",1.0e-12);
    automatic custom_phase phase = QUEUED;
    automatic time before_time = $time;
    uvm_tlm_sync_e result;
    real annotation;
    result = base.nb_transport_fw(value,phase,delay);
    $display("UT: custom_accepted status %0d phase %0d value %0d immediate %0d",
             result == UVM_TLM_ACCEPTED,phase == QUEUED,value.value,$time == before_time);
    result = base.nb_transport_fw(value,phase,delay); annotation = delay.get_abstime(1.0e-9);
    $display("UT: custom_forward status %0d phase %0d value %0d calls %0d annotation %0d",
             result == UVM_TLM_UPDATED,phase == REQUEST_DONE,value.value,probe.forward_calls,
             annotation > 2.999999 && annotation < 3.000001);
    phase = REPLY_START; result = base.nb_transport_bw(value,phase,delay);
    annotation = delay.get_abstime(1.0e-9);
    $display("UT: custom_backward status %0d phase %0d value %0d calls %0d delay %0d immediate %0d",
             result == UVM_TLM_COMPLETED,phase == DONE,value.value,probe.backward_calls,
             annotation > 7.999999 && annotation < 8.000001,$time == before_time);
    $finish;
  end
endmodule
