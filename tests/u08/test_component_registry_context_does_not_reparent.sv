/*
:name: test_component_registry_context_does_not_reparent
:description: an explicit factory context does not change the created component parent (IEEE 1800.2-2020 Section 8.2.3.2.4)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.3.2.4 8.3.1.4.1 13.1.3.1 13.1.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_registry_context_does_not_reparent.expected
*/
// The explicit context selects an instance override. The resulting
// component is constructed with the actual parent passed to create.

module test_component_registry_context_does_not_reparent;
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
    automatic context_component parent = new("env", null);
    automatic uvm_factory factory = uvm_factory::get();
    base_env value;
    factory.set_inst_override_by_type(base_env::get_type(), derived_env::get_type(), "other.child");
    value = base_env::type_id::create("child", parent, "other");
    $display("UT: type %s parent %0d full %s", value.get_type_name(), value.get_parent() == parent,
             value.get_full_name());
    $finish;
  end
endmodule
