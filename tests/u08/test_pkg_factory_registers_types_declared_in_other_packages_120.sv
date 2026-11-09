/*
:name: test_pkg_factory_registers_types_declared_in_other_packages_120
:description: component and object types declared with utility macros in other packages are registered by static initialization, so the factory finds and creates them by name although no code names them (IEEE 1800.2-2020 Section 8.2.3.2.3)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.3.2.3 8.2.4.2.3 8.2.3.2.7 8.2.4.2.7 F.3.1.3 F.4.1.3 8.3.1.7.2 8.3.1.7.3 8.3.1.5 8.3.2.2.3 B.2.1.2 B.2.1.3 B.2.1.4 B.2.1.5 F.7.3.1 13.1.3.2 1800-2023 26.2 26.3 6.8 8.25 7.8.2 7.9.4 7.9.6
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pkg_factory_registers_types_declared_in_other_packages_120.expected
:files: helpers120_pkg/agent_pkg120.sv helpers120_pkg/seq_pkg120.sv helpers120_pkg/env_pkg120.sv helpers120_pkg/ext_pkg120.sv
*/
// What it checks:
// 1. Component and object types declared with utility macros in a package are
//    registered with the factory by static initialization, before run_test and
//    without any code naming them.
// 2. Creation by name returns components and objects of types declared in
//    other packages, with the given names and parent, castable to their base
//    types from the package that declares the base.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 8.2.3.2.3 (UVM-USER-PACKAGE-STATIC-REGISTRATION) gives rule 1
//    above. Setup: Two types of the environment package and two of the
//    extension package are never named in the test file; one other type of
//    each package is named. Before run_test, query the factory by the four
//    type names. Expected: All four names are registered, and the wrappers
//    found by name report those type names.
// 2. 1800.2-2020 8.3.1.5 (UVM-USER-PACKAGE-CREATE-BY-NAME) gives rule 2 above.
//    Setup: In build_phase, create a component and an object of each of the
//    never-named types, and an extension agent and item, by name with the test
//    as parent or context. Expected: Each object has the requested type and
//    name, the components are children of uvm_test_top, and the extension
//    agent and item cast to agent120 and item120.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Four types live in the environment and extension packages and are never named
// in this file; the file names one other type of each of those packages, so
// both are part of the design. Before run_test, the factory must already report
// all four type names as registered and return their wrappers. In build_phase,
// creation by name must return a component and an object of each requested type
// with the given names, and the extension agent and item must cast to their
// base types from the agent package. The agent, sequence, environment and
// extension packages are separate files listed in :files: in that order, so
// each package is compiled before the packages that import it. Only the lines
// that begin with "UT: " are compared.
`include "uvm_macros.svh"

module test_pkg_factory_registers_types_declared_in_other_packages_120;
  import uvm_pkg::*;
  import agent_pkg120::*;

  // One named type of each extra package keeps both packages in the design.
  env_pkg120::env120 env_handle120;
  ext_pkg120::ext_driver120 driver_handle120;

  class t extends uvm_test;
    `uvm_component_utils(t)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      uvm_factory factory;
      uvm_component c;
      uvm_object o;
      agent120 agent;
      item120 item;
      bit ok;
      super.build_phase(phase);
      factory = uvm_coreservice_t::get().get_factory();
      c = factory.create_component_by_name("named_env120", get_full_name(), "env", this);
      $display("UT: component %s %s", c == null ? "null" : c.get_type_name(),
               c == null ? "null" : c.get_full_name());
      c = factory.create_component_by_name("ext_agent120", get_full_name(), "agent", this);
      ok = $cast(agent, c) && agent != null;
      $display("UT: agent cast %0d %s %s", ok, ok ? agent.get_type_name() : "none",
               ok ? agent.get_full_name() : "none");
      o = factory.create_object_by_name("named_cfg120", get_full_name(), "cfg");
      $display("UT: object %s %s", o == null ? "null" : o.get_type_name(),
               o == null ? "null" : o.get_name());
      o = factory.create_object_by_name("ext_item120", get_full_name(), "item");
      ok = $cast(item, o) && item != null;
      $display("UT: item cast %0d %s %s", ok, ok ? item.get_type_name() : "none",
               ok ? item.get_name() : "none");
    endfunction
  endclass

  initial begin
    automatic uvm_factory factory = uvm_coreservice_t::get().get_factory();
    automatic uvm_object_wrapper env_wrapper = factory.find_wrapper_by_name("named_env120");
    automatic uvm_object_wrapper cfg_wrapper = factory.find_wrapper_by_name("named_cfg120");
    $display("UT: registered %0d %0d %0d %0d", factory.is_type_name_registered("named_env120"),
             factory.is_type_name_registered("named_cfg120"),
             factory.is_type_name_registered("ext_agent120"),
             factory.is_type_name_registered("ext_item120"));
    $display("UT: wrappers %s %s", env_wrapper == null ? "null" : env_wrapper.get_type_name(),
             cfg_wrapper == null ? "null" : cfg_wrapper.get_type_name());
    run_test("t");
  end

  initial begin
    #1000;
    $fatal(1, "pkg120 watchdog expired");
  end
endmodule
