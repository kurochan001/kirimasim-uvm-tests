/*
:name: test_component_default_automatic_config_calls_application_during_build
:description: automatic configuration build dispatch and explicit override (13.1.5.2)
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.5.2 13.1.5.1 13.1.4.1.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_default_automatic_config_calls_application_during_build.expected
*/
// What it checks:
// 1. Automatic configuration is enabled by default.
// 2. Enabled build configuration calls the virtual application method with
//    default verbosity zero.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.1.5.2 (UVM-COMPONENT-AUTOMATIC-CONFIG-DEFAULT-ENABLED)
//    gives rule 1 above. Setup: Use an ordinary derived component without
//    overriding use_automatic_config. Expected: The query returns one and
//    build invokes application once.
// 2. 1800.2-2020 13.1.5.1 (UVM-COMPONENT-CONFIG-BUILD-VIRTUAL-DISPATCH) gives
//    rule 2 above. Setup: Count overridden calls and then explicitly apply
//    once more. Expected: Build gives one application; explicit reuse gives
//    two, both with zero verbosity.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_component_default_automatic_config_calls_application_during_build;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  // Observe virtual dispatch only; resource matching has separate fixtures.
  class configured extends uvm_component;
    int applications = 0;
    int verbose_total = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void apply_config_settings(bit verbose = 0);
      applications++;
      verbose_total += verbose;
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    configured child;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      child = new("child", this);
    endfunction
    function void end_of_elaboration_phase(uvm_phase phase);
      $display("UT: build enabled %0d applications %0d verbose %0d",
               child.use_automatic_config(), child.applications, child.verbose_total);
      child.apply_config_settings();
      $display("UT: explicit applications %0d verbose %0d",
               child.applications, child.verbose_total);
    endfunction
  endclass
  initial run_test("t");
endmodule
