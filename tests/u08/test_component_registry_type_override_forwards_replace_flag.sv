/*
:name: test_component_registry_type_override_forwards_replace_flag
:description: component registry type overrides honor both preserve and replace requests (IEEE 1800.2-2020 Section 8.2.3.2.5)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.3.2.5 8.2.3.2.4 8.3.1.4.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_registry_type_override_forwards_replace_flag.expected
*/
// All override types derive from the original component type. Distinct
// leaf names allow both registry creations to coexist under the same parent.

module test_component_registry_type_override_forwards_replace_flag;
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
    base_env retained;
    base_env replaced;
    base_env::type_id::set_type_override(first_env::get_type());
    base_env::type_id::set_type_override(second_env::get_type(), 0);
    retained = base_env::type_id::create("retained", parent);
    base_env::type_id::set_type_override(second_env::get_type(), 1);
    replaced = base_env::type_id::create("replaced", parent);
    $display("UT: retained %s replaced %s", retained.get_type_name(), replaced.get_type_name());
    $display("UT: parents %0d %0d", retained.get_parent() == parent,
        replaced.get_parent() == parent);
    $finish;
  end
endmodule
