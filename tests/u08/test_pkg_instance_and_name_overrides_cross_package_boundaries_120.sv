/*
:name: test_pkg_instance_and_name_overrides_cross_package_boundaries_120
:description: an instance override relative to the test replaces only the matching agent that the environment package creates, and a by-name type override applies to by-name creation of a sequence from another package (IEEE 1800.2-2020 Section 8.2.3.2.6)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.3.2.6 8.3.1.4.1 8.3.1.4.2 8.3.1.5 8.2.3.2.4 B.2.1.2 B.2.1.3 13.1.4.1.1 15.2.1.2.1 15.2.1.2.3 1800-2023 26.2 26.3 6.8 8.25 7.8.2 7.9.4 7.9.6
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pkg_instance_and_name_overrides_cross_package_boundaries_120.expected
:files: helpers120_pkg/agent_pkg120.sv helpers120_pkg/seq_pkg120.sv helpers120_pkg/env_pkg120.sv helpers120_pkg/ext_pkg120.sv
*/
// What it checks:
// 1. An instance override set through type_id relative to the test replaces
//    only the matching component that another package creates.
// 2. A by-name type override applies to by-name creation of a sequence
//    declared in another package, keeping the given name, with or without a
//    parent path.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 8.2.3.2.6 (UVM-USER-PACKAGE-RELATIVE-INSTANCE-OVERRIDE) gives
//    rule 1 above. Setup: The test sets an override of agent120 by
//    ext_agent120 for env.a1 relative to itself; the environment package
//    creates a0 and a1 through type_id. Expected: a0 stays agent120 and a1 is
//    ext_agent120, whose inherited build still creates driver120.
// 2. 1800.2-2020 8.3.1.4.2 (UVM-USER-PACKAGE-TYPE-OVERRIDE-BY-NAME) gives rule
//    2 above. Setup: The test overrides seq120 with ext_seq120 by name and
//    creates s0 with its own path and s1 with an empty path by the name
//    seq120. Expected: Both sequences are ext_seq120 named s0 and s1, and both
//    drivers receive data 20 and 21.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The test sets an instance override for env.a1 relative to itself, so only the
// second agent that the environment package creates through type_id must be the
// extension agent; its inherited build still creates the original driver. A by-
// name type override from seq120 to ext_seq120 must make both sequences created
// by name the extension sequence, keeping the given names, so both drivers must
// receive data 20 and 21. The agent, sequence, environment and extension
// packages are separate files listed in :files: in that order, so each package
// is compiled before the packages that import it. Only the lines that begin
// with "UT: " are compared.
`include "uvm_macros.svh"

module test_pkg_instance_and_name_overrides_cross_package_boundaries_120;
  import uvm_pkg::*;
  import agent_pkg120::*;
  import seq_pkg120::*;
  import env_pkg120::*;
  import ext_pkg120::*;

  class t extends uvm_test;
    `uvm_component_utils(t)
    env120 env;
    seq120 s0;
    seq120 s1;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      uvm_factory factory;
      uvm_object o;
      super.build_phase(phase);
      factory = uvm_coreservice_t::get().get_factory();
      agent120::type_id::set_inst_override(ext_agent120::get_type(), "env.a1", this);
      factory.set_type_override_by_name("seq120", "ext_seq120");
      env = env120::type_id::create("env", this);
      o = factory.create_object_by_name("seq120", get_full_name(), "s0");
      if (!$cast(s0, o) || s0 == null) $fatal(1, "s0 is not a seq120");
      o = factory.create_object_by_name("seq120", "", "s1");
      if (!$cast(s1, o) || s1 == null) $fatal(1, "s1 is not a seq120");
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fork
        s0.start(env.a0.sqr);
        s1.start(env.a1.sqr);
      join
      phase.drop_objection(this);
    endtask

    function void report_phase(uvm_phase phase);
      env.show120();
      show_started120();
    endfunction
  endclass

  initial run_test("t");

  initial begin
    #1000;
    $fatal(1, "pkg120 watchdog expired");
  end
endmodule
