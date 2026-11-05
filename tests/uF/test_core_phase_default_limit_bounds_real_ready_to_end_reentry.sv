/*
:name: test_core_phase_default_limit_bounds_real_ready_to_end_reentry
:description: A core-selected global limit bounds repeated positive-time ready-to-end objections
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.4.1.4.10 F.4.1.4.11 9.3.1.3.3 9.3.1.3.5 13.1.4.3.2 1800-2023 6.21 8.20 8.21 13.5.2 18.13.3 18.13.4
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=trial
:expected_exit: 0
:expected_stdout: @test_core_phase_default_limit_bounds_real_ready_to_end_reentry.expected
*/
// Only main raises ready objections; all drops finish before the next callback.
module test_core_phase_default_limit_bounds_real_ready_to_end_reentry;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class trial extends uvm_test;
    `uvm_component_utils(trial)
    int ready_calls=0, drops=0;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    task main_phase(uvm_phase phase);
      phase.raise_objection(this); #1ns; phase.drop_objection(this);
    endtask
    virtual function void phase_ready_to_end(uvm_phase phase);
      if (phase.get_name()=="main") begin
        ready_calls++;
        phase.raise_objection(this);
        fork begin #1ns; drops++; phase.drop_objection(this); end join_none
      end
    endfunction
    virtual function void extract_phase(uvm_phase phase);
      $display("DETAIL: completed ready drops %0d",drops);
      $display("UT: bounded_ready calls %0d core_limit %0d",
        ready_calls,uvm_coreservice_t::get().get_phase_max_ready_to_end());
    endfunction
  endclass
  initial begin
    uvm_coreservice_t::get().set_phase_max_ready_to_end(3);
    run_test();
  end
  initial begin #30ns; $fatal(1,"original64 phase watchdog"); end
endmodule
