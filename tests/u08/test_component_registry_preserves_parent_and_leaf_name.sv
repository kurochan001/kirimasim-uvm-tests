/*
:name: test_component_registry_preserves_parent_and_leaf_name
:description: a registry-created replacement component receives the requested parent and name (IEEE 1800.2-2020 Section 8.2.3.2.4)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.3.2.4 8.3.1.4.2 13.1.3.1 13.1.3.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_registry_preserves_parent_and_leaf_name.expected
*/
// A type override replaces the component type. Creation retains the
// requested leaf name and actual parent in the component hierarchy.

module test_component_registry_preserves_parent_and_leaf_name;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class context_component extends uvm_component;
    `uvm_component_utils(context_component)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass

  class base_env extends uvm_component;
    `uvm_component_utils(base_env)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  class derived_env extends base_env;
    `uvm_component_utils(derived_env)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass

  initial begin
    context_component parent = new("env", null);
    uvm_factory factory = uvm_factory::get();
    base_env value;
    factory.set_type_override_by_type(base_env::get_type(), derived_env::get_type());
    value = base_env::type_id::create("child", parent);
    $display("UT: type %s parent %0d full %s", value.get_type_name(), value.get_parent() == parent,
             value.get_full_name());
    $finish;
  end
endmodule
