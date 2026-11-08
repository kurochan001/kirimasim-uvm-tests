/*
:name: test_pkg_type_overrides_from_another_package_apply_to_type_id_create_120
:description: type overrides that the test sets through type_id to classes of an extension package apply when the agent and sequence packages create the original driver and item types (IEEE 1800.2-2020 Section 8.2.3.2.5)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.3.2.5 8.2.4.2.5 8.3.1.4.2 8.2.3.2.4 8.2.4.2.4 B.2.1.2 B.2.1.3 13.1.4.1.1 15.2.1.2.1 15.2.1.2.3 1800-2023 26.2 26.3 6.8 8.25 7.8.2 7.9.4 7.9.6
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pkg_type_overrides_from_another_package_apply_to_type_id_create_120.expected
:files: helpers120_pkg/agent_pkg120.sv helpers120_pkg/seq_pkg120.sv helpers120_pkg/env_pkg120.sv helpers120_pkg/ext_pkg120.sv
*/
// The agent and sequence packages do not import the extension package. The test
// overrides the driver and item types with extension classes before building
// the environment, so both drivers must be the extension driver, every
// delivered item must be the extension item, and the agents and the sequence
// data must stay unchanged. The agent, sequence, environment and extension
// packages are separate files listed in :files: in that order, so each package
// is compiled before the packages that import it. Only the lines that begin
// with "UT: " are compared.
`include "uvm_macros.svh"

module test_pkg_type_overrides_from_another_package_apply_to_type_id_create_120;
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
      super.build_phase(phase);
      driver120::type_id::set_type_override(ext_driver120::get_type());
      item120::type_id::set_type_override(ext_item120::get_type());
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
