/*
:name: test_component_registry_relative_instance_override_is_scoped
:description: a component registry instance override applies only below its supplied parent (IEEE 1800.2-2020 Section 8.2.3.2.6)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.3.2.6 8.2.3.2.4 13.1.3.1 13.1.3.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_registry_relative_instance_override_is_scoped.expected
*/
// Configure a relative leaf override through the registry. The selected
// and unaffected components still receive their actual constructor parents.

module test_component_registry_relative_instance_override_is_scoped;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class owner extends uvm_component;
    `uvm_component_utils(owner)
    function new(string name, uvm_component parent=null); super.new(name, parent); endfunction
  endclass

  class base_env extends uvm_component;
    `uvm_component_utils(base_env)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  class first_env extends base_env;
    `uvm_component_utils(first_env)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  class second_env extends base_env;
    `uvm_component_utils(second_env)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass

  initial begin
    automatic owner parent = new("env");
    automatic owner other = new("other");
    base_env selected;
    base_env outside;
    base_env::type_id::set_inst_override(first_env::get_type(), "leaf", parent);
    selected = base_env::type_id::create("leaf", parent);
    outside = base_env::type_id::create("leaf", other);
    $display("UT: selected %s full %s parent %0d", selected.get_type_name(),
             selected.get_full_name(), selected.get_parent() == parent);
    $display("UT: outside %s full %s parent %0d", outside.get_type_name(),
             outside.get_full_name(), outside.get_parent() == other);
    $finish;
  end
endmodule
