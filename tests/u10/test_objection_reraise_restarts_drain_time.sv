/*
:name: test_objection_reraise_restarts_drain_time
:description: raising an objection during drain cancels the earlier completion (IEEE 1800.2-2020 Section 10.5.1.3.4)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.3.4 10.5.1.3.7 9.6 10.5.1.3.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_TESTNAME=t
:expected_stdout: @test_objection_reraise_restarts_drain_time.expected
*/
// A new raise during drain cancels that drain iteration. The final drop
// starts a full new drain interval; extraction must wait for its completion.

module test_objection_reraise_restarts_drain_time;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      uvm_objection objections = phase.get_objection();
      objections.set_drain_time(this, 3);
      phase.raise_objection(this);
      #1;
      phase.drop_objection(this);
      #1;
      phase.raise_objection(this);
      $display("UT: raised again at two %0d", $time == 2);
      #1;
      phase.drop_objection(this);
    endtask
    function void extract_phase(uvm_phase phase);
      $display("UT: extract at six %0d", $time == 6);
    endfunction
  endclass
  initial run_test();
endmodule
