/*
:name: test_phase_schedule_names_preserve_default_zero_and_explicit_single_parent_context
:description: phase schedule names preserve default zero and explicit single parent context
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.6.5 9.3.1.6.4 9.3.1.6.1 9.3.1.4.4 9.3.1.3.1 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_schedule_names_preserve_default_zero_and_explicit_single_parent_context.expected
*/
// What it checks:
// 1. get_schedule_name identifies the enclosing schedule context.
// 2. The schedule-name hierarchy argument defaults to zero.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.3.1.6.5 (UVM-PHASE-CONTRACT-SCHEDULE-NAME-CONTEXT) gives
//    rule 1 above. Setup: Each of two schedules has exactly one enclosing
//    schedule level and a node for the original implementation. Expected:
//    left/right names identify their respective single parent.
// 2. 1800.2-2020 9.3.1.6.5 (UVM-PHASE-CONTRACT-SCHEDULE-NAME-DEFAULT) gives
//    rule 2 above. Setup: Each of two schedules has exactly one enclosing
//    schedule level and a node for the original implementation. Expected:
//    Default and explicit zero agree; explicit one gives the same single-level
//    name.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// One schedule ancestor avoids choosing among ambiguous nested prose.
module test_phase_schedule_names_preserve_default_zero_and_explicit_single_parent_context;
  import uvm_pkg::*;
  class task_imp extends uvm_task_phase;
    static task_imp singleton;
    function new(string name="singleton53");super.new(name);endfunction
    static function task_imp get();
      if (singleton==null) singleton=new();return singleton;
    endfunction
    virtual task exec_task(uvm_component comp,uvm_phase phase);endtask
  endclass

  initial begin
    automatic uvm_phase left=new("left53",UVM_PHASE_SCHEDULE);
    automatic uvm_phase right=new("right53",UVM_PHASE_SCHEDULE);
    automatic task_imp imp=task_imp::get();
    uvm_phase first,second;
    left.add(imp);right.add(imp);first=left.find(imp);second=right.find(imp);
    $display("UT: phase_schedule_name left %0d right %0d default_zero %0d explicit_hier %0d",
      first.get_schedule_name()=="left53",second.get_schedule_name()=="right53",
      first.get_schedule_name()==first.get_schedule_name(0),
      first.get_schedule_name(1)=="left53");
    $finish;
  end
endmodule
