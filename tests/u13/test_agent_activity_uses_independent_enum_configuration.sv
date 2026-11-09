/*
:name: test_agent_activity_uses_independent_enum_configuration
:description: agent status reflects active and passive enum settings independently (IEEE 1800.2-2020 Section 13.4.2.2)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.4.2.2 13.4.2.1 F.2.1.7 C.4.2.2.1 C.4.2.2.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_agent_activity_uses_independent_enum_configuration.expected
*/
// What it checks:
// 1. Agent get_is_active reports the activity mode configured for that agent.
// 2. The active/passive enum supplies the named activity designators used by
//    typed agent configuration and status.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.4.2.2 (UVM-AGENT-ACTIVITY-QUERY) gives rule 1 above.
//    Setup: Separate agents are explicitly configured active and passive
//    before querying. Expected: Each query agrees with its configured activity
//    enumeration.
// 2. 1800.2-2020 F.2.1.7 (UVM-PKG-ACTIVE-PASSIVE-DESIGNATORS-89) gives rule 2
//    above. Setup: Reuse unchanged already-measured tests that explicitly cite
//    F.2.1.7. One configures two independent agents using the enum type and
//    opposite named values;the other observes active defaults in independent
//    agents. Current source fingerprints and the pinned ordinary configuration
//    remain compatible. Expected: The typed passive/active selections and
//    separate active defaults retain their selected enum status.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Configure children before their build callbacks run. No driver is needed
// to inspect agent activity; the status API itself is the observation.
module test_agent_activity_uses_independent_enum_configuration;
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
      uvm_config_db#(uvm_active_passive_enum)::set(this, "first", "is_active", UVM_PASSIVE);
      uvm_config_db#(uvm_active_passive_enum)::set(this, "second", "is_active", UVM_ACTIVE);
      first = new("first", this);
      second = new("second", this);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #1;
      $display("UT: first_passive %0d second_active %0d",
               first.get_is_active() == UVM_PASSIVE, second.get_is_active() == UVM_ACTIVE);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #50; $fatal(1, "agent status watchdog expired"); end
endmodule
