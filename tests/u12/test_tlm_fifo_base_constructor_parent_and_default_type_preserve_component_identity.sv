/*
:name: test_tlm_fifo_base_constructor_parent_and_default_type_preserve_component_identity
:description: tlm fifo base constructor parent and default type preserve component identity (IEEE 1800.2-2020 Section 12.2.8.1.7)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.1.7 12.2.8.1.1 13.1.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_base_constructor_parent_and_default_type_preserve_component_identity.expected
*/
// Concrete original probes call the declared base constructor with an omitted
// parent or an explicit actual component parent. Default T is checked through
// an exact base view. No base default method algorithm, abstract construction,
// factory behavior or unspecified empty component name is inferred.
module test_tlm_fifo_base_constructor_parent_and_default_type_preserve_component_identity;
  import uvm_pkg::*;
  class owner extends uvm_component;
    function new(); super.new("owner",null); endfunction
  endclass
  class static_probe extends uvm_tlm_fifo_base#();
    function new(); super.new("static_fifo"); endfunction
  endclass
  class child_probe extends uvm_tlm_fifo_base#(int);
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  initial begin
    automatic owner parent_value = new();
    automatic static_probe standalone = new();
    automatic child_probe child = new("child_fifo",parent_value);
    automatic uvm_tlm_fifo_base#(int) exact_default = standalone;
    automatic uvm_component component_view = child;
    $display("UT: fifo_base_static name %0d default_type %0d",
             standalone.get_name() == "static_fifo",exact_default == standalone);
    $display("UT: fifo_base_child name %0d parent %0d full_name %0d component %0d",
             child.get_name() == "child_fifo",child.get_parent() == parent_value,
             child.get_full_name() == "owner.child_fifo",component_view == child);
    $finish;
  end
endmodule
