/*
:name: test_agent_activity_defaults_to_active_for_independent_instances
:description: unconfigured agents report the documented active default (IEEE 1800.2-2020 Section 13.4.2.2)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.4.2.2 13.4.2.1 F.2.1.7
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_agent_activity_defaults_to_active_for_independent_instances.expected
*/
// Configure children before their build callbacks run. No driver is needed
// to inspect agent activity; the status API itself is the observation.
module test_agent_activity_defaults_to_active_for_independent_instances;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class status_agent extends uvm_agent;
    `uvm_component_utils(status_agent)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    status_agent first;
    status_agent second;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      first = new("first", this);
      second = new("second", this);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #1;
      $display("UT: active %0d %0d distinct %0d", first.get_is_active() == UVM_ACTIVE,
               second.get_is_active() == UVM_ACTIVE, first != second);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #50; $fatal(1, "agent status watchdog expired"); end
endmodule
