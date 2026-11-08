/*
:name: test_pkg_type_id_create_builds_a_hierarchy_from_other_packages_120
:description: a test class declared in a package is created by run_test from its name, and type_id::create calls in the environment, agent and sequence packages build the hierarchy and the item flow (IEEE 1800.2-2020 Section 8.2.3.2.4)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.3.2.4 8.2.4.2.4 F.7.3.1 8.2.3.2.3 B.2.1.3 B.2.1.2 13.1.3.2 13.1.4.1.1 14.2.3.1 15.2.1.2.1 15.2.1.2.3 14.2.6.2 14.2.6.3 1800-2023 26.2 26.3 6.8 8.25 7.8.2 7.9.4 7.9.6
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pkg_type_id_create_builds_a_hierarchy_from_other_packages_120.expected
:files: helpers120_pkg/agent_pkg120.sv helpers120_pkg/seq_pkg120.sv helpers120_pkg/env_pkg120.sv helpers120_pkg/ext_pkg120.sv
*/
// The test class sits in a package of this file that the module only imports,
// so run_test must find it by name. The environment, agent and sequence
// packages each create their children or items through type_id. Every component
// must have the given name and parent and its own type, and each driver must
// receive the two items of the sequence started on its agent. The agent,
// sequence, environment and extension packages are separate files listed in
// :files: in that order, so each package is compiled before the packages that
// import it. Only the lines that begin with "UT: " are compared.
`include "uvm_macros.svh"

// The module only imports this package; run_test finds the test by name.
package test_pkg_hierarchy120;
  import uvm_pkg::*;
  import agent_pkg120::*;
  import seq_pkg120::*;
  import env_pkg120::*;

  class hierarchy_test120 extends uvm_test;
    `uvm_component_utils(hierarchy_test120)
    env120 env;
    seq120 s0;
    seq120 s1;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = env120::type_id::create("env", this);
      s0 = seq120::type_id::create("s0");
      s1 = seq120::type_id::create("s1");
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
      $display("UT: test %s %s", get_type_name(), get_full_name());
      env.show120();
      show_started120();
    endfunction
  endclass
endpackage

module test_pkg_type_id_create_builds_a_hierarchy_from_other_packages_120;
  import uvm_pkg::*;
  import test_pkg_hierarchy120::*;

  initial run_test("hierarchy_test120");

  initial begin
    #1000;
    $fatal(1, "pkg120 watchdog expired");
  end
endmodule
