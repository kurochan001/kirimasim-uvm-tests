/*
:name: test_component_run_phase_kills_remaining_task_and_descendant_after_all_objections_drop
:description: component run phase kills remaining task and descendant after all objections drop
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.4.1.5 13.1.4 9.6 F.7.3.1 F.7.3.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_run_phase_kills_remaining_task_and_descendant_after_all_objections_drop.expected
*/
// What it checks:
// 1. The common run phase can end without its selected task returning and
//    kills its later write.
// 2. The ended common run phase kills its selected task descendant instead of
//    permitting later counter updates.
// 3. The component phase interface separates objection-controlled phase
//    lifetime from task return and ends selected task processes with the
//    phase.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.1.4.1.5 (UVM-COMPONENT-EXT-COMMON-TASK-KILL) gives rule 1
//    above. Setup: Use the linked original fixtures and their explicit public
//    phase, factory or hierarchy calls. Preserve the declared original types,
//    scope, arguments and expected observations; no private implementation
//    state supplies an oracle. Expected: The common run phase can end without
//    its selected task returning and kills its later write.
// 2. 1800.2-2020 13.1.4.1.5 (UVM-COMPONENT-EXT-COMMON-DESCENDANT-KILL) gives
//    rule 2 above. Setup: Use the linked original fixtures and their explicit
//    public phase, factory or hierarchy calls. Preserve the declared original
//    types, scope, arguments and expected observations; no private
//    implementation state supplies an oracle. Expected: The ended common run
//    phase kills its selected task descendant instead of permitting later
//    counter updates.
// 3. 1800.2-2020 13.1.4 (UVM-COMPONENT-EXT-TASK-LIFETIME-INTERFACE) gives rule
//    3 above. Setup: Use the linked original fixtures and their explicit
//    public phase, factory or hierarchy calls. Preserve the declared original
//    types, scope, arguments and expected observations; no private
//    implementation state supplies an oracle. Expected: The component phase
//    interface separates objection-controlled phase lifetime from task return
//    and ends selected task processes with the phase.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_component_run_phase_kills_remaining_task_and_descendant_after_all_objections_drop;
  import uvm_pkg::*;
  class lifetime_worker extends uvm_component;
    bit entered=0,forked=0,late_write=0;
    int ticks=0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual task run_phase(uvm_phase phase);
      entered=1;
      fork begin forked=1; forever begin #1; ticks++; end end join_none
      #5; late_write=1;
      wait(0);
    endtask
  endclass
  class holding_actor extends uvm_component;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this); #1; phase.drop_objection(this);
    endtask
  endclass
  initial begin
    automatic holding_actor actor=new("actor47",null);
    automatic lifetime_worker worker=new("worker",actor);
    automatic uvm_coreservice_t service=uvm_coreservice_t::get();
    int before_ticks;
    service.get_root().set_finish_on_completion(0); run_test();
    before_ticks=worker.ticks; #7;
    $display("UT: common_lifetime entered %0d forked %0d late %0d fork_alive %0d",
             worker.entered,worker.forked,worker.late_write,worker.ticks>before_ticks);
    $finish;
  end
  initial begin #100; $fatal(1,"common lifetime watchdog"); end
endmodule
