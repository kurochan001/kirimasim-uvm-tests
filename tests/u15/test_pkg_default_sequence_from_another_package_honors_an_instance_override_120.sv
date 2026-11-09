/*
:name: test_pkg_default_sequence_from_another_package_honors_an_instance_override_120
:description: a default sequence given as the wrapper of a sequence from another package is created for each sequencer of the agent package with the sequencer path as context, so an instance override set by the test replaces it on one sequencer only (IEEE 1800.2-2020 Section 15.3.5)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.5 8.3.1.5 8.3.2.2.3 8.2.4.2.6 8.3.1.4.1 14.2.4.1 C.4.2.2.1 8.2.3.2.4 B.2.1.2 B.2.1.3 15.2.1.2.1 15.2.1.2.3 1800-2023 26.2 26.3 6.8 8.25 7.8.2 7.9.4 7.9.6
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pkg_default_sequence_from_another_package_honors_an_instance_override_120.expected
:files: ../u08/helpers120_pkg/agent_pkg120.sv ../u08/helpers120_pkg/seq_pkg120.sv ../u08/helpers120_pkg/env_pkg120.sv ../u08/helpers120_pkg/ext_pkg120.sv
*/
// What it checks:
// A default sequence given as the wrapper of a sequence from another package
// is created with the sequencer's full name as context and the wrapper's type
// name as name, so instance overrides for that path apply.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.3.5 (UVM-USER-PACKAGE-DEFAULT-SEQUENCE-WRAPPER) gives the
// rule above. Setup: Both sequencers of the agent package get the wrapper of
// seq120 for main_phase; the test sets an instance override to ext_seq120 for
// env.a1.sqr.seq120 relative to itself. Expected: a0 runs seq120 and a1 runs
// ext_seq120, both named seq120 and started in the main phase; the drivers
// receive 10 and 11, and 20 and 21.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The test gives the wrapper of seq120 as the main_phase default sequence of
// both sequencers and sets an instance override to ext_seq120 for the path that
// the second sequencer forms from its full name and the wrapper's type name.
// The first sequencer must run seq120 and the second ext_seq120, both named
// seq120 and both started in the main phase, and the drivers must receive data
// 10 and 11 and data 20 and 21. The agent, sequence, environment and extension
// packages are separate files listed in :files: in that order, so each package
// is compiled before the packages that import it. Only the lines that begin
// with "UT: " are compared.
`include "uvm_macros.svh"

module test_pkg_default_sequence_from_another_package_honors_an_instance_override_120;
  import uvm_pkg::*;
  import agent_pkg120::*;
  import seq_pkg120::*;
  import env_pkg120::*;
  import ext_pkg120::*;

  class t extends uvm_test;
    `uvm_component_utils(t)
    env120 env;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = env120::type_id::create("env", this);
      uvm_config_db #(uvm_object_wrapper)::set(this, "env.a0.sqr.main_phase", "default_sequence",
                                               seq120::get_type());
      uvm_config_db #(uvm_object_wrapper)::set(this, "env.a1.sqr.main_phase", "default_sequence",
                                               seq120::get_type());
      seq120::type_id::set_inst_override(ext_seq120::get_type(), "env.a1.sqr.seq120", this);
    endfunction

    task main_phase(uvm_phase phase);
      phase.raise_objection(this);
      #10;
      phase.drop_objection(this);
    endtask

    function void report_phase(uvm_phase phase);
      env.show120();
      show_started120();
      $display("UT: phases %s %s", phase120["uvm_test_top.env.a0.sqr"],
               phase120["uvm_test_top.env.a1.sqr"]);
    endfunction
  endclass

  initial run_test("t");

  initial begin
    #1000;
    $fatal(1, "pkg120 watchdog expired");
  end
endmodule
