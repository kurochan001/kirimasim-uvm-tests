/*
:name: test_run_test_pre_abort_callbacks_follow_component_cleanup_and_precede_final_aborted_state
:description: Run-test abort callbacks observe PRE_ABORT after component hooks and final observes ABORTED before termination
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.6.2.4 F.6.2.5 F.2.10 F.3.1.1 F.7.3.2 13.1.4.6 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_run_test_pre_abort_callbacks_follow_component_cleanup_and_precede_final_aborted_state.expected
*/
// What it checks:
// 1. Registered pre-abort callbacks execute before root termination.
// 2. die notifies component/callback cleanup and records ABORTED before
//    terminating simulation.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.6.2.4 (UVM-PACKAGE-AUDIT-CALLBACK-PRE-ABORT) gives rule 1
//    above. Setup: A standalone original component and registered callback
//    precede a direct die call; a SystemVerilog final block observes
//    termination. Expected: The callback runs once in PRE_ABORT after the
//    selected component pre_abort hook.
// 2. 1800.2-2020 F.7.3.2 (UVM-PACKAGE-AUDIT-ROOT-ABORT-PROGRESSION) gives rule
//    2 above. Setup: A standalone original component and registered callback
//    precede a direct die call; a SystemVerilog final block observes
//    termination. Expected: Both selected hooks run in PRE_ABORT, component
//    before callback; final sees ABORTED and the delayed continuation never
//    runs.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Direct die terminates the run; the final block observes completion.
module test_run_test_pre_abort_callbacks_follow_component_cleanup_and_precede_final_aborted_state;
  import uvm_pkg::*;
  int component_calls=0,callback_calls=0;
  bit callback_state=1,component_state=1,ordered=1,delayed_continuation=0;
  class component_type extends uvm_component;
    function new(); super.new("component57",null); endfunction
    virtual function void pre_abort();
      component_calls++; component_state &= get_core_state()==UVM_CORE_PRE_ABORT;
    endfunction
  endclass
  class callback_type extends uvm_run_test_callback;
    function new(); super.new("abort57"); endfunction
    virtual function void pre_abort();
      callback_calls++; callback_state &= get_core_state()==UVM_CORE_PRE_ABORT;
      ordered &= component_calls==1;
    endfunction
  endclass
  initial begin
    automatic component_type component=new();
    automatic callback_type callback_instance=new();
    if (!uvm_run_test_callback::add(callback_instance))
      $fatal(1,"callback setup failed");
    #1; uvm_root::get().die(); #1; delayed_continuation=1;
  end
  final begin
    $display(
      "UT: abort_callbacks component %0d callback %0d states %0d ordered %0d final_state %0d",
      component_calls==1,callback_calls==1,component_state && callback_state,ordered,
      get_core_state()==UVM_CORE_ABORTED);
    $display("UT: abort_callbacks no_delayed_continuation %0d",!delayed_continuation);
  end
endmodule
