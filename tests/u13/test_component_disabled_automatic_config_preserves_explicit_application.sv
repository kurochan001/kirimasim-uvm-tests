/*
:name: test_component_disabled_automatic_config_preserves_explicit_application
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
:expected_stdout: @test_component_disabled_automatic_config_preserves_explicit_application.expected
*/
module test_component_disabled_automatic_config_preserves_explicit_application;
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
    function bit use_automatic_config(); return 0; endfunction
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
