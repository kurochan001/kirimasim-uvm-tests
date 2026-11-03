/*
:name: test_component_run_phase_return_does_not_end_an_objection_held_phase
:description: component run phase return does not end an objection held phase
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.4.1.5 13.1.4 9.6 F.7.3.1 F.7.3.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_run_phase_return_does_not_end_an_objection_held_phase.expected
*/
module test_component_run_phase_return_does_not_end_an_objection_held_phase;
  import uvm_pkg::*;
  class returned_worker extends uvm_component;
    bit returned=0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual task run_phase(uvm_phase phase); returned=1; endtask
  endclass
  class holding_actor extends uvm_component;
    returned_worker worker;
    bit ended=0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this); #3;
      $display("UT: common_held returned %0d ended %0d",worker.returned,ended);
      phase.drop_objection(this);
    endtask
    virtual function void phase_ended(uvm_phase phase);
      super.phase_ended(phase); if (phase.get_name()=="run") ended=1;
    endfunction
  endclass
  initial begin
    automatic holding_actor actor=new("actor47",null);
    automatic returned_worker worker=new("worker",actor);
    automatic uvm_coreservice_t service=uvm_coreservice_t::get();
    actor.worker=worker;
    service.get_root().set_finish_on_completion(0); run_test();
    $display("UT: common_after_drop ended %0d",actor.ended); $finish;
  end
  initial begin #100; $fatal(1,"common return watchdog"); end
endmodule
